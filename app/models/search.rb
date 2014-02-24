class Search
  include Elasticsearch::Model

  Models = [Diary, News, Poll, Post, Tracker, WikiPage, Page]

  FACET_BY_TYPE = {
    'news'    => 'section',
    'post'    => 'forum',
    'tracker' => 'category'
  }

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

  attr_accessor :query, :page, :type, :value, :start, :order
  attr_reader :results

  def run
    query = Jbuilder.encode do |json|
      json.query do
        json.filtered do
          json.query do
            json.simple_query_string do
              json.query @query
            end
          end

          filters = []
          filters << {
            :range => {
              :created_at => {
                :gte => @start,
                :lte => Date.tomorrow
              }
            }
          } if @start
          filters << { :term => { facet => @value } } if @value
          json.filter do
            json.and filters
          end if filters.any?
        end
      end

      json.aggs do
        json.types do
          json.terms do
            json.field "_type"
            json.order do
              json._count "desc"
            end
          end
        end unless @type
        json.facets do
          json.terms do
            json.field facet
            json.order do
              json._count "desc"
            end
          end
        end if facet && !@value
        json.periods do
          json.date_range do
            json.field "created_at"
            json.ranges available_periods
          end
        end unless @start
      end

      json.sort [ { :created_at => :desc } ] if @order
    end

    query = MultiJson.load(query, :symbolize_keys => true)

    if @type
      klass = @type.camelize.constantize rescue nil
      if Models.include? klass
        response = klass.search query
      end
    end

    if response.nil?
      models  = MultipleModels.new(Models)
      options = {
       :index => models.map { |c| c.index_name },
       :type  => models.map { |c| c.document_type }
      }
      search  = Searching::SearchRequest.new(models, query, options)
      response = Response::Response.new(models, search)
    end

    @response = response.page(@page)
  end

  def available_periods
    [
      { :from => "now-1w/d" },  # last week
      { :from => "now-1M/d" },  # last month
      { :from => "now-1y/d" },  # last year
    ]
  end

  def types
    aggregations.types.buckets
  end

  def facets
    aggregations.facets.buckets
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
end
