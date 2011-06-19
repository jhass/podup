class PodsController < ApplicationController
  def index
    @pods = Pod.order('score DESC')
  end
end
