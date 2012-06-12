require './lib/reevoomark'

rm = ReevooMark.new('tmp/cache', 'http://localhost:3000/reevoomark/embeddable_reviews.html', 'SNY', 'DSCHX1.CEH')
body = rm.render
style = '<link rel="stylesheet" href="http://localhost:3000/stylesheets/reevoomark/embedded_reviews.css.inlineme" type="text/css" />
'

html = <<-HTML
<html>
<head>#{style}</head>
<body><div style="width: 500px; margin: auto">#{body}</div></body>
</html>
HTML

run Proc.new { |env| [200, { 'Content-Type' => 'text/html' }, [html]] }
