class ApiError < StandardError
  attr_reader :status, :message

  def initialize(status, message=nil)
    @status = status
    @message = message || status.to_s.humanize
  end
end