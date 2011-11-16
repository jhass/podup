module Geocoder
  def search_ip(query)
    lookup = get_lookup(ip_lookups.first)
    lookup.search(query)
  end
end
