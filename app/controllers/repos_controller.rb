class ReposController < ApplicationController
  before_action :set_repo, only: [:show, :edit, :update, :destroy]

  # GET /repos
  # GET /repos.json
  def index
    @repos = Repo.all
  end

  # GET /repos/1
  # GET /repos/1.json
  def show
    @repos = Repo.all
    final_params = []
    unless @repo.scans.last == nil
      last_scan_id = @repo.scans.last.id  
      final_query_array = ["SELECT * FROM issues WHERE scan_id = ?", "ORDER BY issues.severity DESC"]
      final_params.push(last_scan_id)
      final_query = final_query_array.join(" ")
      @issues = Issue.find_by_sql [final_query, *final_params]
    end
    
    
  end

  # GET /repos/new
  def new
    @repos = Repo.all
    @repo = Repo.new
  end

  # GET /repos/1/edit
  def edit
    @repos = Repo.all
  end

  # POST /repos
  # POST /repos.json
  def create
    params = Repo.get_repo(repo_params[:name], repo_params[:owner])
    if params == {}
      puts "@@@ Found bad url"
       redirect_to root and return
    end

    @repo = Repo.new(params)

    respond_to do |format|
      if @repo.save
        format.html { redirect_to @repo, notice: 'Repo was successfully created.' }
        format.json { render :show, status: :created, location: @repo }
      else
        format.html { render :new }
        format.json { render json: @repo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repos/1
  # PATCH/PUT /repos/1.json
  def update
    @repos = Repo.all
    respond_to do |format|
      if @repo.update(repo_params)
        format.html { redirect_to @repo, notice: 'Repo was successfully updated.' }
        format.json { render :show, status: :ok, location: @repo }
      else
        format.html { render :edit }
        format.json { render json: @repo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repos/1
  # DELETE /repos/1.json
  def destroy
    @repo.destroy
    respond_to do |format|
      format.html { redirect_to repos_url, notice: 'Repo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repo
      @repo = Repo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repo_params
      params.require(:repo).permit(:name, :owner, :full_name, :html_url, :description, :language, :size)
    end
end
