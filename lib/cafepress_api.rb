# Copyright 2011 Benjamin Lee Smith <benjamin.lee.smith@gmail.com>
#
# This file is part of CafePressAPI.
# CafePressAPI is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# CafePressAPI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CafePressAPI.  If not, see <http://www.gnu.org/licenses/>.

require 'rexml/document'
require 'open-uri'
require 'product_genders'
require 'product_colors'
require 'json'
require 'net/http'
module CafePressAPI
  RESULTS_PER_PAGE = 100
  FRONT_PRODUCT_VIEW = 'f'
  BACK_PRODUCT_VIEW = 'b'
  ADD_TO_CART_BASE_URL = 'http://www.cafepress.com/cp/addtocart.aspx'
  VIEW_CART_BASE_URL = 'http://www.cafepress.com/cp/viewcart.aspx'
  include ProductGenders
  include ProductColors

  def self.store_url(cafepress_store_id)
    "http://cafepress.com/#{cafepress_store_id}"
  end

  # Generates a url to add one product to a CafePress cart.
  # This isn't part of the CafePress API, use at your own risk!
  def self.add_to_cart_url(product_id, size, color, quantity, keep_shopping_url)
    "#{ADD_TO_CART_BASE_URL}?color_#{product_id}=#{color}&size_#{product_id}=#{size}&qty_#{product_id}=#{quantity}&keepshopping=#{keep_shopping_url}&storeid=search"
  end

  def self.user_token(app_key = ENV['cp_app_key'], email = ENV['cp_email'], password = ENV['cp_password'])
    content = ''
    open("http://open-api.cafepress.com/authentication.getUserToken.cp?appKey=#{app_key}&email=#{email}&password=#{password}") do |s| content = s.read end
    REXML::Document.new(content).root.text
  end

  def self.get_store_products(cafepress_store_id, app_key = ENV['cp_app_key'])
    s = Net::HTTP.get_response(URI.parse("http://open-api.cafepress.com/product.listByStore.cp?v=3&appKey=#{app_key}&storeId=#{cafepress_store_id}&page=0&pageSize=#{RESULTS_PER_PAGE}")).body
    result = Hash.from_xml(s)['products']['product']
  end

  def self.get_design_url(cafepress_design_id, app_key = ENV['cp_app_key'])
    content = ''
    open("http://open-api.cafepress.com/design.find.cp?v=3&appKey=#{app_key}&id=#{cafepress_design_id}") do |s| content = s.read end
    doc = REXML::Document.new(content)
    doc.root.attributes['mediaUrl']
  end

  def self.get_store(cafepress_store_id, app_key = ENV['cp_app_key'])
    content = ''
    open("http://open-api.cafepress.com/store.findByStoreId.cp?v=3&appKey=#{app_key}&storeId=#{cafepress_store_id}") do |s| content = s.read end
    doc = REXML::Document.new(content)

    {:store_id => cafepress_store_id, :description => doc.root.attributes['description'], :title => doc.root.attributes['title']}
  end
end
