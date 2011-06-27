module Job
  class Approval
    @queue = :hp_checks
    
    def self.perform(pod_id)
      pod = Pod.find(pod_id)
      if pod.is_up?
        pod.update_attributes(:accepted => true)
        pod.compute_reliability!
        pod.compute_score!
        pod.enqueue!
        #TODO send mail
      else
        pod.update_attributes
        #TODO send mail
      end
    end
  end
end
