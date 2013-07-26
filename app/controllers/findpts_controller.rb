require 'net/http'
require 'xmlsimple'
include FindptsHelper

class FindptsController < ApplicationController

	def get_peak_trough

		@fred_code = params[:fredcode]

		if @fred_code.present?
			@url = "http://api.stlouisfed.org/fred/series/observations?series_id=#{@fred_code}&api_key=18cfd1b1c1472627c59bf110ad4253f3"
			xml_data = Net::HTTP.get_response(URI.parse(@url)).body
			@data = XmlSimple.xml_in(xml_data)

			@parsed_data = []

			@data["observation"].each do |item| 
				if item["value"].to_f != 0.0
					@parsed_data << [Time.parse(item["date"]).utc.to_i*1000, item["value"].to_f] 
				end
			end
		end

		@delta = params[:delta]

		if @delta.present?
			data_for_pt_finder = []
			@data["observation"].each do |item| 
				if item["value"].to_f != 0.0
					data_for_pt_finder << [Time.parse(item["date"]), item["value"].to_f] 
				end
			end
			@dates_values = pt_dates(data_for_pt_finder, @delta)
		end
	end
end