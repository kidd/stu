class BucketsController < ApplicationController
  def create
    @bucket = Bucket.create(params[:bucket])

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
