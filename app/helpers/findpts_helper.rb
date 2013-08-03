module FindptsHelper

	def pt_dates(array = [], delta, units)
		date_value = []

		#do an if statement here to check that delta is a legitimate number
		#do an if statement to check that delta is >= zero.

		mn = 1.0/0.0
		mx = -1.0/0.0

		mnpos = nil
		mxpos = nil

		index_pos = nil
		index_neg = nil

		look_for_max = 1
		index_counter = 0

		if units.include?("Percent")
			array.each do |i|
				this = i[1]*1.0
				#each element in the array has a date [0] and value [1]

				if this > mx
					mx = this
					mxpos = i[0]
					index_pos = index_counter
				end

				if this < mn
					mn = this
					mnpos = i[0]
					index_neg = index_counter
				end

				if look_for_max == 1
					if (-1.0*delta.to_f) > (this - mx)							
						if date_value.present?
							prev_m = date_value.last[1]
							prev_index = date_value.last[3]
							date_value << [mxpos, mx, "peak", index_pos, mx - prev_m, index_pos - prev_index]
						else
							date_value << [mxpos, mx, "peak", index_pos]
						end

						mn = this
						mnpos = i[0]
						index_neg = index_counter
						look_for_max = 0
					end
				else
					if delta.to_f < (this - mn)
						if date_value.present?
							prev_m = date_value.last[1]
							prev_index = date_value.last[3]
							date_value << [mnpos, mn, "trough", index_neg, mn - prev_m, index_neg - prev_index]
						else
							date_value << [mnpos, mn, "trough", index_neg]
						end

						mx = this
						mxpos = i[0]
						index_pos = index_counter
						look_for_max = 1
					end
				end
				
				index_counter = index_counter + 1
			end
		else
			array.each do |i|
				this = i[1]*1.0
				#each element in the array has a date [0] and value [1]

				if this > mx
					mx = this
					mxpos = i[0]
					index_pos = index_counter
				end

				if this < mn
					mn = this
					mnpos = i[0]
					index_neg = index_counter
				end

				if look_for_max == 1
					if (-1.0*delta.to_f) > ((this - mx)/(mx*1.0))							
						if date_value.present?
							prev_m = date_value.last[1]
							prev_index = date_value.last[3]
							date_value << [mxpos, mx, "peak", index_pos, (mx*1.0)/(prev_m*1.0) - 1, index_pos - prev_index]
						else
							date_value << [mxpos, mx, "peak", index_pos]
						end
						mn = this
						index_neg = index_counter
						mnpos = i[0]
						look_for_max = 0
					end
				else
					if delta.to_f < ((this - mn)/(mn*1.0))
						if date_value.present?
							prev_m = date_value.last[1]
							prev_index = date_value.last[3]
							date_value << [mnpos, mn, "trough", index_neg, (mn*1.0)/(prev_m*1.0) - 1, index_neg - prev_index]
						else
							date_value << [mnpos, mn, "trough", index_neg]
						end
						mx = this
						index_pos = index_counter
						mxpos = i[0]
						look_for_max = 1
					end
				end

				index_counter = index_counter + 1
			end
		end

		return date_value
	end

	def data_frequency(series_hash)
		frequency = series_hash["series"][0]["frequency"]

		if frequency.include?("Daily")
			num_frequency = 200
		elsif frequency.include?("Weekly")
			num_frequency = 80
		elsif frequency.include?("Monthly")
			num_frequency = 60
		elsif frequency.include?("Quarterly")
			num_frequency = 20
		elsif frequency.include?("Annual")
			num_frequency = 10
		end
				
		return num_frequency
	end

	def get_math_calcs(array = [], p_or_t)
		value_arr = []
		index_arr = []

		new_array = array[1..-1]
		if new_array.present?
			new_array.each do |i|
				if i[2] == p_or_t
					value_arr << i[4].to_f
					index_arr << i[5].to_f
				end
			end
		end

		value_title = ""
		index_title = ""

		if p_or_t == "peak"
			value_title = "Trough to Peak Values Diff"
			index_title = "Trough to Peak Num Periods"
		else
			value_title = "Peak to Trough Values Diff"
			index_title = "Peak to Trough Num Periods"
		end

		final_vals = value_arr.length > 0 ? calc_maths(value_arr).unshift(value_title) : nil
		final_inds = index_arr.length > 0 ? calc_maths(index_arr).unshift(index_title) : nil

		return [final_vals, final_inds]
	end

	def calc_maths(array = [])
		maxim = array.max
		minim = array.min

		total = array.inject(:+)
		len = array.length

		ave = total.to_f/(len*1.0)
		sorted = array.sort
		med = len % 2 == 1 ? sorted[len/2] : (sorted[(len-1)/2] + sorted[len/2]).to_f/2

		return [ave, med, maxim, minim, len]
	end	

	def graph_pts(dates_array = [], data_array = [], frequency, p_or_t, units)
		# account for beginning and end where there aren't any values
		# create percentage values from one going forward and backward
		
		# the array contains dates of peaks and troughs
		# what format does the full data array come in?
		final_array = {}
		sub_array = []

		if units.include?("Percent")
			dates_array.each do |i|
				if i[2] == p_or_t	
					if i[3] < (frequency - 1)
						for j in 0..(frequency - i[3] - 1)
							sub_array << nil
						end

						for k in 0..i[3]
							sub_array << data_array[k][1] - (i[1]*1.0)
						end
					else
						for m in (i[3] - frequency)..i[3]
							sub_array << data_array[m][1] - (i[1]*1.0)
						end
					end

					for n in (i[3]+1)..(i[3] + frequency)
						if n > (data_array.length - 1)
							sub_array << nil
						else
							sub_array << data_array[n][1] - (i[1]*1.0)
						end
					end

					final_array["#{i[0]}"] = sub_array
					sub_array = []
				end
			end
		else
			dates_array.each do |i|
				if i[2] == p_or_t	
					if i[3] < (frequency - 1)
						for j in 0..(frequency - i[3] - 1)
							sub_array << nil
						end

						for k in 0..i[3]
							sub_array << data_array[k][1]/(i[1]*1.0)
						end
					else
						for m in (i[3] - frequency)..i[3]
							sub_array << data_array[m][1]/(i[1]*1.0)
						end
					end

					for n in (i[3]+1)..(i[3] + frequency)
						if n > (data_array.length - 1)
							sub_array << nil
						else
							sub_array << data_array[n][1]/(i[1]*1.0)
						end
					end

					final_array["#{i[0]}"] = sub_array
					sub_array = []
				end
			end
		end
		return final_array
	end


end












