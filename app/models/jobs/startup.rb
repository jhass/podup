module Job
  class Startup
    @queue = :common
    
    def self.perfom
      begin
        Pod.accepted.each do |pod|
        pod.enqueue!
      end
      rescue ActiveRecord::StatementInvalid
      end
    end
  end
end
