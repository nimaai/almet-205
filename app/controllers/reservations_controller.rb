class ReservationsController < ApplicationController

  def index
    @reservations = if params[:past]
                      Reservation.past
                    elsif params[:future]
                      futures = Reservation.future
                      if params[:present] and present = Reservation.present
                        futures.unshift present
                      end
                      futures
                    else
                      Reservation.order(:arrival)
                    end
  end

  def new
    @reservation = Reservation.new
    @reservation.visitor = Visitor.new
  end

  def create
    @reservation = Reservation.new reservation_params

    if @reservation.save
      flash[:success] = "New reservation successfully created"
      redirect_to reservations_path(future: true) and return
    else
      flash.now[:error] = @reservation.errors.full_messages.join(", ")
      render :new and return
    end
  end

  def destroy
    Reservation.find(params[:id]).destroy
    redirect_to :back, flash: { success: "Reservation successfully deleted" }
  end

  private

    def reservation_params
      params.require(:reservation).permit(:arrival, :departure, :adults, :children, :bedclothes_service, visitor_attributes: [:firstname, :lastname, :street, :zip, :city, :country, :mobile, :phone, :email])
    end

end
