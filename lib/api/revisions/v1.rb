# encoding: UTF-8

module Astor
  class APIv1 < Grape::API

    version 'v1', :using => :path
    format :json

    helpers do
      def collector ; env['options'][:collector]              ; end
      def id        ; params[:id]                             ; end
      def type      ; params[:id].split('-')[0]               ; end 
      def metric    ; params[:id].split('-')[1..-1].join('.') ; end 
    end

    before do
      header 'Access-Control-Allow-Origin', '*'
    end
  
    resource :metrics do

      get '/' do
        collector.keys
      end

      get '/:id' do
        from  = params['from'] ? Time.parse(params['from']) : Time.now.utc - 60 * 60
        to    = params['to']   ? Time.parse(params['to'])   : Time.now.utc

        if params['offset'] =~ /-\d+\w+/
          units, scale = params['offset'].scan(/(\d+)(\w+)/)[0]
          seconds = case scale
            when /day/    then units.to_i * 60 * 60 * 24
            when /hour/   then units.to_i * 60 * 60
            when /minute/ then units.to_i * 60
          end
          from = Time.now.utc - seconds
        end

        data = collector.find(id, from, to)

        {id: id, type: type, key: metric, data: data}
      end

      post '/:id' do
        value = params['value']
        collector.save(type, metric, value)
      end

      delete '/:id' do
        collector.delete(id)
      end
    end

  end
end
