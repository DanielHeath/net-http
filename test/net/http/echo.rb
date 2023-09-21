require 'webrick'

class Echo < WEBrick::HTTPServlet::AbstractServlet
  def do_GET request, response
    response.status = 200
    response['Content-Type'] = 'text/plain'
    response.body = request.path[1..-1]
  end
end

server = WEBrick::HTTPServer.new :Port => 8000, :AccessLog => []
server.mount('/', Echo)

trap 'INT' do server.shutdown end
server.start