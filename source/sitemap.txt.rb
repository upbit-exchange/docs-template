<% sitemap.resources.each do |page| %>
    <%= "#{URI.join(config[:host], page.url)}\n" if page.url !~ /\.(css|js|eot|svg|woff|ttf|png|jpg|jpeg|gif|keep)$/ %>
<% end %>