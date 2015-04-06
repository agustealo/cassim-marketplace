def get_trending_urls(url)
  driver = Selenium::WebDriver.for :firefox
  driver.get(url)
  driver.switch_to.default_content
  css_selector2 = ".image-wrap"
  ary = driver.find_elements(:css, css_selector2)
  trending_item_urls = []
  ary.each do |a|
    trending_item_urls << a.attribute('href')
  end
  driver.quit
  trending_item_urls
end

def create_trending_products(links)
  links.each do |link|
    response = RestClient.get(link).body
    noko = Nokogiri::HTML(response)


    name = noko.css('div#listing-right-column span[itemprop="name"]').text
    price = noko.css('span#listing-price .currency-value').text
    desc = noko.css('div#description-text').text.strip
    vendor = noko.css('span[itemprop="title"]').text
    properties = noko.css('ul.properties li').text
    image_url = noko.css('ul#image-carousel li:nth-child(1)').attr('data-full-image-href').value

    Product.create(
      name: name,
      description: desc,
      price: price,
      vendor: Vendor.create(name: vendor),
      properties: properties,
      etsy_image_url: image_url
    )
  end

end

namespace :etsy do

  desc "rake -T"
  task scrape: :environment do
    Product.delete_all

    etsy_trending_links = get_trending_urls("http://etsy.com/trending")
    create_trending_products(etsy_trending_links)

  end
end
