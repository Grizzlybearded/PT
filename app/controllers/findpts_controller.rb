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

			@get_type_url = "http://api.stlouisfed.org/fred/series?series_id=#{@fred_code}&api_key=18cfd1b1c1472627c59bf110ad4253f3"
			get_type_xml_data = Net::HTTP.get_response(URI.parse(@get_type_url)).body
			@get_type_data = XmlSimple.xml_in(get_type_xml_data)

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
			@dates_values = pt_dates(data_for_pt_finder, @delta, @get_type_data["series"][0]["units"])

			@data_for_peaks = graph_pts(@dates_values, @parsed_data, data_frequency(@get_type_data), "peak", @get_type_data["series"][0]["units"])

			@data_for_troughs = graph_pts(@dates_values, @parsed_data, data_frequency(@get_type_data), "trough", @get_type_data["series"][0]["units"])

			@peak_calcs   = get_math_calcs(@dates_values, "peak")
			@trough_calcs = get_math_calcs(@dates_values, "trough")
		end
	end
end