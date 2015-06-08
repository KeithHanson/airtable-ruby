module Airtable

  class Table < Resource
    # Maximum results per request
    LIMIT_MAX = 100

    # Fetch all records iterating through offsets until retrieving the entire collection
    # all(:sort => ["Name", :desc])
    def all(options={})
      offset = nil
      results = []
      begin
        options.merge!(:limit => LIMIT_MAX, :offset => offset)
        response = records(options)
        results += response.records
        offset = response.offset
      end until offset.nil? || offset.empty? || results.empty?
      results
    end

    # Fetch records from the sheet given the list options
    # Options: limit = 100, offset = "as345g", sort = ["Name", "asc"]
    # records(:sort => ["Name", :desc], :limit => 50, :offset => "as345g")
    def records(options={})
      options["sortField"], options["sortDirection"] = options.delete(:sort) if options[:sort]
      results = self.class.get(worksheet_url, query: options).parsed_response
      RecordSet.new(results)
    end

    # Returns record based given row id
    def find(id)
      result = self.class.get(worksheet_url + "/" + id).parsed_response
      Record.new(result["fields"].merge("id" => result["id"])) if result.present? && result["id"]
    end

    # Creates a record by posting to airtable
    def create(record)
      result = self.class.post(worksheet_url,
        :body => { "fields" => record.fields }.to_json,
        :headers => { "Content-type" => "application/json" }).parsed_response
      if result.present? && result["id"].present?
        record.id = result["id"]
        record
      else # failed
        false
      end
    end

    # Replaces record in airtable based on id
    def update(record)
      fields = record.fields
      fields.delete("id")


      result = self.class.put(worksheet_url + "/" + record.id,
        :body => { "fields" => fields  }.to_json,
        :headers => { "Content-type" => "application/json" }).parsed_response

      binding.pry

      if result.present? && result["ID"].present?
        record
      else # failed
        false
      end
    end

    # Deletes record in table based on id
    def destroy(id)
      self.class.delete(worksheet_url + "/" + id).parsed_response
    end

    protected

    def worksheet_url
      "/#{app_token}/#{URI.encode(worksheet_name)}"
    end
  end # Table

end # Airtable
