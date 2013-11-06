require 'net/http'
require 'active_support'
require 'csv'

csvFile = "data.csv"

host = '10.55.10.13'
port = '3000'
path = '/issues.json'
key = 'e3dad26b1b87228ca344506a87fa936b2444e569' # redmine api key


class RedmineImport
  def initialize(host,port, key)
    @host = host
    @port = port
    @key = key
  end
  
  def readCsv(filename)
    @csvData = [];
    
    CSV.foreach(filename, {
      :col_sep => ';',
      :headers => true
    }) do |row|
      @csvData.push(row)
    end
    
  end
  
  def importIssues()
    
    @csvData.each{ |row| 
      sendRequest('/issues.json', buildRequest(row))
    }
    
  end
  
  def buildRequest(row)
    body = ActiveSupport::JSON.encode({
      :key => @key,
      :issue => {
        :project_id => 7,
        :tracker_id => 6,
        :status_id => 1,
        #:priority_id => 0,
        :subject => row['Subject'],
        :description => '',
        #:category_id => 0,
        :assigned_to_id => 0,
        :custom_fields => [
          { :id => 3, :value => row['E-Mail']}, # E-Mail
          { :id => 4, :value => row['Website']}, # Website
          { :id => 5, :value => row['Contact Person']}, # Contact Person
          { :id => 6, :value => row['Country']}, # Country
          { :id => 7, :value => 'Some contract information'}, # Contract Information
          { :id => 8, :value => row['Address']}, # Address
          { :id => 9, :value => row['Phone']} # Phone
        ]
      }
    })
    return body
  end
  
  def sendRequest(path, data)
    request = Net::HTTP::Post.new(path, initheader = {'Content-Type' =>'application/json'})
    request.body = data
    response = Net::HTTP.new(@host, @port).start {|http| http.request(request) }
    puts "Response #{response.code} #{response.message}: #{response.body}"
  end
  
end


ri = RedmineImport.new(host,port,key)
ri.readCsv(csvFile)
ri.importIssues()