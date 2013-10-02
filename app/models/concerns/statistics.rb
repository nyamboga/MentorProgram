module Statistics
  #extend ActiveSupport::Concern

  SecondsInDay = 86400

  def average_response_in_days(requests)
    average_response(requests) / SecondsInDay
  end

  def average_response(requests)
    total_time = 0
    requests.each do |request|
      total_time += request.answer.created_at - request.created_at
    end
    total_time / requests.count
  end
      
end