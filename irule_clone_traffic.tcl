when HTTP_REQUEST {
  if {[HTTP::method] eq "POST"}{
    set http_request "[HTTP::request]end"
    set http_request [string map {"https" "http" "443" "80" "\r\n\r\nend" ""} $http_request]
    set conn [connect -timeout 3000 -idle 30 -status conn_status local-vs]
    log local0. "Connect returns: <$conn> and conn status: <$conn_status> "
    set conn_info [connect info -idle -status $conn]
    log local0. "Connect info: <$conn_info>"
    if {[HTTP::header "Content-Length"] ne "" && [HTTP::header "Content-Length"] <= 1048576}{
      set content_length [HTTP::header "Content-Length"]
    } else {
        set content_length 1048576
    }
    if { $content_length > 0} {
      HTTP::collect $content_length
    } else {
          #log local0. "no payload found"
          #log local0. "http request $http_request"
        
     
    }
  }
}
when HTTP_REQUEST_DATA {
  log local0. "payload found: [HTTP::payload]" 
     log local0. "http request$http_request"
     set payload [HTTP::payload]

  }


when HTTP_RESPONSE {
    HTTP::collect [HTTP::header Content-Length]
}

when HTTP_RESPONSE_DATA {
    set b64_response [b64encode [HTTP::payload]]
    set http_request "$http_request\r\n64response: $b64_response\r\n\r\n$payload"
    set send_info [send -timeout 3000 -status send_status $conn $http_request]
    set recv_data [recv -timeout 3000 -status recv_status 393 $conn]
    close $conn
}