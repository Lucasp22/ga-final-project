class BookingsController < ApplicationController
  def index
    authorize_customer
    @bookings = Booking.where("customer_id = ?", current_customer.id)
  end

  def new
    @booking = Booking.new
    @tour = Tour.find params[:tour_id]
   end

  def show
    authorize_customer
    @booking = Booking.find params[:id]
  end

  def create
    # Every booking needs to belong to a customer
    # If the customer already has an account and is logged in, then we use
    # that customer object.

    # If they are not logged in, then we need to try making a new customer
    # record using the details they entered into the form.

    # The saving of the new customer, could fail (e.g. they didn't enter a
    # password, the email address is already in use, etc.)

    # If we can't save the new customer, then we redirect back to the booking
    # new page, immediately.

    customerPassword = SecureRandom.hex(8)

    customer = Customer.new
    customer.email = params[:stripeEmail]
    customer.password = customerPassword

    unless customer.save
      flash[:error] = 'Sorry, we could not save your customer details.'
      redirect_to(new_booking_url(tour_id: params[:tour_id])) && return
    end

    # Now that we have saved the customer, we set that customer as logged in
    session[:customer_id] = customer.id

    # is the customer logged in?
    # if not, make a customer object using details they send in a form
    # if it fails,
    # make a booking object

    # assign all the variables
    # try and save it
    # if saving successful, redirect tobooking#show
    # if not, redirect booking#new form again
    booking = Booking.new
    booking.start_date = params[:start_date]
    booking.status = 'placed' # params[:status]
    booking.tour_id = params[:tour_id]
    booking.customer_id = customer.id
    booking.payment_reference = params[:stripeToken]

    unless booking.save
      flash[:error] = 'Sorry, we could not save your booking details.'
      redirect_to(new_booking_url) && return
    end

    # TODO: we now saved the booking, we now need to add Booking People to the booking.

    # Process Stripe payment

    flash[:success] = "Thank you for booking. Your booking ID is #{booking.id}. Your account has been created with your email (#{customer.email}) and password (#{customerPassword})."

    redirect_to booking
  end

  # this is not actually delete method, just changing the status of the booking from placed to cancelled
  def destroy
    booking = Booking.find(params[:id])
    booking.status = 'cancelled'
    booking.save
    flash[:success] = 'Booking Cancelled!'
    redirect_to tours_path
  end
end
