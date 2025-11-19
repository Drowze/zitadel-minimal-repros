# dead simple ruby server to inspect incoming requests

app = ->(env) {
  req = Rack::Request.new(env)
  request_body = req.body.read if req.env['CONTENT_LENGTH']
  request_headers = req.env.select { |k, _v| k.start_with?('HTTP_') }.reject do |k, _v|
    # not interested in these headers
    %w[HTTP_HOST HTTP_USER_AGENT HTTP_ACCEPT_ENCODING].include?(k)
  end

  $stdout.puts <<~MESSAGE
    Received request!
    endpoint: #{req.request_method} #{req.path}
    query string: #{req.query_string.inspect}
    headers: #{request_headers.inspect}
    body: #{request_body}
  MESSAGE
  $stdout.flush

  [200, {}, ['']]
}

run app
