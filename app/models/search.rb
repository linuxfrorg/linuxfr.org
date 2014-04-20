class Search
  include Elasticsearch::Model

  Models = [Diary, News, Poll, Post, Tracker, WikiPage, Page]

  FACET_BY_TYPE = {
    'news'    => 'section',
    'post'    => 'forum',
    'tracker' => 'category'
  }

  INDICES_BOOST = {
    pages: 1000,  # Old + long body => needs a very large boost to compete with news
    news: 3
  }

  FIELDS_BOOST = [
    "_all",
    "title^5",
    "section^2",
    "forum^2",
    "category^2",
    "username^2",
    "tags^1.5"
  ]

  PER_PAGE = 15

  class MultipleModels < Array
    def client
      Elasticsearch::Model.client
    end

    def ancestors
      []
    end

    def default_per_page
      PER_PAGE
    end
  end

  attr_accessor :query, :page, :type, :value, :start, :order, :tags
  attr_reader :results

  def run
    query = {
      query: {
        filtered: ->{
          filtered = {
            query: {
              simple_query_string: {
                query: @query,
                fields: FIELDS_BOOST
              }
            }
          }

          filters = []
          filters << {
            range: {
              created_at: { gte: @start, lte: Date.tomorrow }
            }
          } if @start
          filters << { term: { facet => @value } } if @value
          @tags.each do |tag|
            filters << { term: { tags: tag } }
          end
          filtered[:filter] = { and: filters } if filters.any?

          filtered
        }.call
      },

      aggs: ->{
        aggs = {}
        aggs[:types] = {
          terms: {
            field: "_type",
            order: { _count: "desc" }
          }
        } unless @type
        aggs[:facets] = {
          terms: {
            field: facet,
            order: { _count: "desc" }
          }
        } if facet && !@value
        aggs[:tags] = {
          terms: {
            field: "tags",
            order: { _count: "desc" },
            min_doc_count: 2,
          }
        }
        aggs[:periods] = {
          date_range: {
            field: "created_at",
            ranges: available_periods
          }
        } unless @start
        aggs
      }.call,

      indices_boost: INDICES_BOOST
    }
    query[:sort] = [ { created_at: :desc } ] if by_date?

    if by_mix?
      query[:query] = {
        function_score: {
          query: query[:query],
          exp: {
            created_at: {
              origin: Date.today.to_s,
              scale: "1w",
              decay: 0.99
            }
          }
        }
      }
    end

    if @type
      klass = @type.camelize.constantize rescue nil
      if Models.include? klass
        response = klass.search query
      end
    end

    if response.nil?
      models  = MultipleModels.new(Models)
      options = {
       index: models.map { |c| c.index_name },
       type: models.map { |c| c.document_type }
      }
      search  = Searching::SearchRequest.new(models, query, options)
      response = Response::Response.new(models, search)
    end

    @response = response.page(@page)
  end

  def available_periods
    [
      { from: "now-1w/d" },  # last week
      { from: "now-1M/d" },  # last month
      { from: "now-1y/d" },  # last year
    ]
  end

  def types
    aggregations.types.buckets
  end

  def facets
    aggregations.facets.buckets
  end

  def tag_buckets
    aggregations.tags.buckets
  end

  def periods
    aggregations.periods.buckets.sort_by {|p| -p.from.to_i }
  end

  def aggregations
    @aggregations ||= Hashie::Mash.new @response.response['aggregations']
  end

  def facet
    @facet ||= FACET_BY_TYPE[@type]
  end

  def total_count
    results.total_count
  end

  def results
    @response.results
  end

  def records
    @response.map { |r| r['_type'].classify.constantize.find(r['_id']) }
  end

  def by_score?
    !by_date? && !by_mix?
  end

  def by_date?
    @order == "date"
  end

  def by_mix?
    @order == "mix"
  end
end
