class BucketsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    BucketWorker.perform_async(params[:bucket])

    respond_to do |format|
      format.json { render json: "" }
    end
  end

  private

  def bucket_params
    params.require(:bucket).permit(:timestamp,
                                   :user,
                                   tracks: [
                                     :name,
                                   ])
  end
end
