module Job
  class Check
    @queue = :normal_checks
    
    def self.perform(pod_id)
      pod = Pod.find(pod_id)
      pod.is_up?
      pod.compute_reliability!
      pod.compute_score!
      pod.compute_uptime!
      pod.enqueue!
    end
  end
end
