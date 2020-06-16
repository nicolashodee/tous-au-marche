class ProducersController < ApplicationController
  before_action :authenticate_producer!, only: [:edit]
  before_action :deny_to_visitors, only: [:show, :edit]

  def index
    @producer = Producer.all
  end

  def show
    @producer = Producer.find(params[:id])
    @favorited = FavoriteProducer.find_by(user_id: current_user.id, producer_id: @producer.id).present?
  end

  def edit
    @producer = Producer.find(params[:id])
  end

  def destroy
    @producer = Producer.find(params[:id])
    @producer.destroy
    if @producer.destroy
      flash[:notice] = 'Vous avez supprimé votre compte producteur. À bientôt !'
      redirect_to root_url
    else 
      flash[:notice] = 'Une erreur est survenue, nous vous invitons à nous contacter directement.'
      redirect_to root_url
    end
  end

  def update
    @producer = Producer.find(params[:id])
    if @producer.update(producer_params)
      flash[:notice] = 'Vos informations ont été mises à jour !'
      redirect_to producer_path(current_producer.id)
    else
      render :edit
    end
  end

  # Add and remove favorite producers for current_user
  def favorite
    @producer = Producer.find(params[:id])
    type = params[:type]
    if type == "favorite"
      current_user.favorites << @producer
      flash[:success] = "Vous avez ajouté #{@producer.first_name} #{@producer.last_name} à votre liste de producteurs favoris."
      redirect_to producer_path
      

    elsif type == "unfavorite"
      current_user.favorites.delete(@producer)
      flash[:notice] = "Vous avez supprimé #{@producer.first_name} #{@producer.last_name} de votre liste de producteurs favoris"
      redirect_to producer_path

    elsif type == "unfavorite-from-user-profile"
      current_user.favorites.delete(@producer)
      flash[:notice] = "Vous avez supprimé #{@producer.first_name} #{@producer.last_name} de votre liste de producteurs favoris"
      redirect_to user_path

    else
      # Type missing, nothing happens
      flash[:notice] = 'Nothing happened.'
      redirect_to root_url
      
    end
  end


  private

  def producer_params
    params.require(:producer).permit(:email, :password, :first_name, :last_name, :description, :address, :phone_number, :website)
  end

  def deny_to_visitors
    if  user_signed_in? || producer_signed_in?
    else
      flash[:danger] = 'Vous devez vous connecter !'
      redirect_to root_path
    end
  end

end