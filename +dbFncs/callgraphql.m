function [ response ] = callgraphql( url, query)
%callgrapql.
qStr = struct('query',query);
options = weboptions('MediaType','application/json');

options.Timeout = 120;
response = webwrite(url, qStr, options)';
response = response.data;

end

