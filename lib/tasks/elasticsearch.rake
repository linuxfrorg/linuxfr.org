namespace :elasticsearch do
  desc <<-EOS
    Import data from your model to ElasticSearch:
      $ rake elasticsearch:import

    Use CLASS to only import data from one class:
      $ rake elasticsearch:import CLASS=News

    Use FORCE to rebuild the index (delete and create):
      $ rake elasticsearch:import FORCE=y
  EOS
  task :import => [:environment] do
    STDOUT.sync = true
    STDERR.sync = true
    require "ansi/progressbar"

    client = Elasticsearch::Model.client
    batch_size = ENV.fetch('BATCH', 1000).to_i

    if ENV['CLASS'].blank?
      klasses = Search::Models
    else
      klasses = ENV['CLASS'].split(',').map {|k| Object.const_get(k) }
    end

    klasses.each do |klass|
      total = klass.indexable.count
      pbar  = ANSI::Progressbar.new(klass.to_s, total)
      index = klass.index_name
      type  = klass.document_type

      if ENV.fetch('FORCE', false)
        klass.__elasticsearch__.create_index! :force => true, :index => index
      end

      klass.indexable.find_in_batches(:batch_size => batch_size) do |batch|
        batch.map! do |a|
          { :index => { :_id => a.id, :data => a.__elasticsearch__.as_indexed_json } }
        end
        response = client.bulk index: index, type: type, body: batch
        pbar.inc response['items'].size
      end
    end

    puts '[IMPORT] Done'
  end
end
