class LibrariesController < ApplicationController
  before_action :set_library, only: [:show, :edit, :update, :destroy]

  def index
    @libraries = policy_scope(Library).includes(:user, :collections).order(created_at: :desc)
  end

  def show
    authorize @library
    @collections = @library.collections.includes(:assets)
  end

  def new
    @library = Library.new
    authorize @library
  end

  def create
    @library = current_user.libraries.build(library_params)
    authorize @library
    if @library.save
      redirect_to @library, notice: "Library created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @library
  end

  def update
    authorize @library
    if @library.update(library_params)
      redirect_to @library, notice: "Library updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @library
    @library.destroy
    redirect_to libraries_path, notice: "Library deleted."
  end

  private

  def set_library
    @library = Library.find(params[:id])
  end

  def library_params
    params.require(:library).permit(:name, :visibility)
  end
end
