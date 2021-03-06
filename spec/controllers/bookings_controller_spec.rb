require 'rails_helper'

RSpec.describe BookingsController, type: :controller do
  describe 'GET index' do

    before do
      tour = Tour.create(
        title: 'St Petersburg to Moscow',
        description: 'Foo',
        price: 500
      )

      customer = Customer.create(
        password: 'bob12345',
        email: 'bob-smith@example.com'
      )

      booking = Booking.create(
        payment_reference: '12345',
        start_date: '2018-09-24',
        tour_id: tour.id,
        customer_id: customer.id
      )

      get(:index, session: { customer_id: customer.id})
    end

    it 'should pass @bookings object to the view' do
      expect(assigns(:bookings)).to be
    end
  end

  describe 'GET new' do
    before do
      tour = Tour.create(
        title: 'St Petersburg to Moscow',
        description: 'Foo',
        price: 500
      )
      get :new, params: { tour_id: tour.id }
    end

    it 'should pass a @tour object to the view' do
      expect(assigns(:tour)).to be
    end
    # TODO: if the customer is logged in, this should be an object
    # if its a brand new customer, it should be nil

    # it 'should pass a @customer variable to the view' do
    #     expect(assigns(:customer)).to be
    # end
  end

  describe 'GET show' do
    # TODO: create a booking, customer, tour object for this to work

    before do
      tour = Tour.create(
        title: 'St Petersburg to Moscow',
        description: 'Foo',
        price: 500
      )

      customer = Customer.create(
        password: 'bob12345',
        email: 'bob-smith@example.com'
      )

      booking = Booking.create(
        payment_reference: '12345',
        start_date: '2018-09-24',
        tour_id: tour.id,
        customer_id: customer.id
      )

      get :show, params: { id: booking.id }
    end

    it 'should pass @booking object to the view' do
      expect(assigns(:booking)).to be
    end
  end

  describe 'POST create' do
    describe 'A booking with an existing customer and successful payment'
    describe 'A booking with an existing customer and payment fails'

    describe 'A booking with a new customer and successful payment' do
      before do
        tour = Tour.create(
          title: 'St Petersburg to Moscow',
          description: 'Foo',
          price: 500
        )

        post :create, params: {
          tour_id: tour,
          start_date: '2018-09-24',
          stripeEmail: 'test@example.com',
          stripeToken: 'abc123'
        }
      end

      it 'should redirect to booking#show page' do
        expect(response).to redirect_to Booking.last
      end

      it 'the booking payment reference should not be empty' do
        expect(Booking.last.payment_reference).not_to be_nil
      end

      # TODO: it should show a success message - thanks for booking
    end

    describe 'A booking with a new customer, but payment fails' do
      it 'should redirect to booking#show'
      it 'the booking payment reference should be empty'
      # TODO: the page should prompt them to try payment again
      # thanks for booking, but we couldn't process your payment...
    end

    describe 'A booking with a new customer, but customer fields are invalid' do

      let (:tour) {
        Tour.create(
          title: 'St Petersburg to Moscow',
          description: 'Foo',
          price: 500
        )
      }

      before do
        post :create, params: {
          tour_id: tour.id,
          start_date: '2018-09-24',
          stripeEmail: nil,
        }
      end

      it 'should redirect to booking#new' do
        expect(response).to redirect_to(new_booking_path(tour_id: tour.id))
      end

      it 'should have a flash error message' do
        expect(flash[:error]).to be_present
        expect(flash[:error]).to match(/Sorry, we could not save your customer details./)

      end
    end
  end
end
