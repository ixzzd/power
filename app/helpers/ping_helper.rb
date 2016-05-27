module PingHelper
  def statistic(params)
      return nil unless params[:pings]
      success_pings = params[:pings].success
      failed_pings = params[:pings].failed
      if !success_pings.empty?
          latency_array = success_pings.map { |x| x[:latency] }
          length = latency_array.length

          mean = (latency_array.sum / length)
          min = latency_array.min
          max = latency_array.max

          sorted = latency_array.sort
          median = (sorted[(length - 1) / 2] + sorted[length / 2]) / 2.0

          sample_variance = latency_array.inject(0) { |accum, i| accum + (i - mean)**2 }
          stdev = Math.sqrt(sample_variance)

          { mean: mean.round(3), max: max.round(3), min: min.round(3), stdev: stdev.round(3), median: median.round(3), expired: failed_pings.count }
      else
          { expired: failed_pings.count }
      end
  end

end
