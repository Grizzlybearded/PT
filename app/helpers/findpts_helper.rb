module FindptsHelper

	def pt_dates(array = [], delta)
		date_value = []

		#do an if statement here to check that delta is a legitimate number
		#do an if statement to check that delta is >= zero.

		mn = 1.0/0.0
		mx = -1.0/0.0

		mnpos = nil
		mxpos = nil

		look_for_max = 1

		array.each do |i|
			this = i[1]*1.0
			#each element in the array has a date [0] and value [1]

			if this > mx
				mx = this
				mxpos = i[0]
			end

			if this < mn
				mn = this
				mnpos = i[0]
			end

			if look_for_max == 1
				if (-1.0*delta.to_f) > ((this - mx)/(mx*1.0))
					date_value << [mxpos, mx, "peak"]
					mn = this
					mnpos = i[0]
					look_for_max = 0
				end
			else
				if delta.to_f < ((this - mn)/(mn*1.0))
					date_value << [mnpos, mn, "trough"]
					mx = this
					mxpos = i[0]
					look_for_max = 1
				end
			end
		end

		return date_value
	end

	def graph_pts(array = [], number_points_before_and_after)
		# account for beginning and end where there aren't any values
		# create percentage values from one going forward and backward


	end
end


