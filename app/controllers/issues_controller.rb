class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy]

  def filter_display

    params[:repo_id]
    params[:severity]
    params[:date_order]
    params[:source]

    @last_scan = Scan.where(repo_id: params[:repo_id]).last
    @repository = Repository.find(params[:repo_id])
    optional_queries_and_params = []

    # Pull out all possible sources
    last_scan_source = @last_scan.sources.distict(true)
    @source_array = []
    last_scan_sources.each do |last_scan_source|
        @soure_array.push(last_scan_source.source)
    end

    # Set up first line of final query array
    final_query_array = [
        "SELECT * FROM issues WHERE scan_id = last_scan.id",
    ]

    # Check for optional params
    
    # Severity filter
    if params[:severity].present? and ["High","Medium","Low"].include?(params[:severity])
        query = "AND severity = ?"
        optional_queries_and_params.push([query, params[:severity]])
    end
    # Date order
    if params[:date_order].present?
      asc_or_desc = DATE_ORDER_MAP[params[:date_order]]
      query = "ORDER BY issues.created_at ?"
      optional_queries_and_params.push([query, asc_or_desc])
    end

    # Source filter
    if params[:source].present?
      query = "AND source = ?"
      optional_queries_and_params.push([query, params[:source]])
    end

    # Add all optional queries and params to final query
    optional_queries_and_params.each do |query, param|
      final_query_array.push(query)
      final_params.push(param)
    end

    final_query = final_query_array.join(" ")
    @issues = Issue.find_by_sql [final_query, *final_params]

  end

  # GET /issues
  # GET /issues.json
  def index
    @issues = Issue.all
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
  end

  # GET /issues/new
  def new
    @issue = Issue.new
  end

  # GET /issues/1/edit
  def edit
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)

    respond_to do |format|
      if @issue.save
        format.html { redirect_to @issue, notice: 'Issue was successfully created.' }
        format.json { render :show, status: :created, location: @issue }
      else
        format.html { render :new }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /issues/1
  # PATCH/PUT /issues/1.json
  def update
    respond_to do |format|
      if @issue.update(issue_params)
        format.html { redirect_to @issue, notice: 'Issue was successfully updated.' }
        format.json { render :show, status: :ok, location: @issue }
      else
        format.html { render :edit }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    @issue.destroy
    respond_to do |format|
      format.html { redirect_to issues_url, notice: 'Issue was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def issue_params
      params.require(:issue).permit(:severity, :source, :description, :detail, :fingerprint, :scan_id)
    end
end
