#Asset Related Functions

"""Gets everything from enterprise asset header table AeAAssetE where asset type in serialized,system and statusCode in active,mainetance,optional shutdown"""
function getActiveSerSysAssets(;rowLimit::Int=10000)
    assetTable = "AeAAssetE"
    assetCrit = ["assetType" => "serialized,system", "statusCode" => "active,maintenance,optional shutdown"]
    makeRequest(assetTable,assetCrit,header;rowLimit=rowLimit) |> parseResponse
end

"""Given a vector of buildings, finds all assets. By default only those not disposed or inactive. Pass activeOnly=false for all assets"""
function getAssetsByBldg(bldgs::Vector{<:Any};activeOnly::Bool=true,rowLimit=10000)
    table = "AeAAssetE"
    bldgList = join(bldgs,",")
    assetStatuses = getAssetStatuses().statusCode |> unique
    if activeOnly
        statuses = filter(x->!(x in ["DISPOSED","INACTIVE"]),assetStatuses) |>
            y-> join(y,",")
    else
        statuses = join(assetStatuses,",")
    end
    crit = ["statusCode" => statuses,"bldg" => bldgList]
    makeRequest(table,crit,header,rowLimit=rowLimit) |> parseResponse
end


"""Gets all asset statuses"""
function getAssetStatuses(;rowLimit=10000)
    table = "AeAAssetStatus"
    makeRequest(table,header,rowLimit=rowLimit) |> parseResponse
end


"""Given a vector of asset numbers, returns the asset data for those numbers."""
function getAssetsByNum(assets::Vector{<:Any};rowLimit::Int=10000)
    @assert length(assets) <=2000 "Searches for over 2000 values not permitted. You passed $(length(assets)). Womp womp..."
    table = "AeAAssetE"
    assetList = join(assets,",")
    assetCrit = ["assetTag"=>assetList]
    makeRequest(table,assetCrit,header,rowLimit=rowLimit) |> parseResponse
end

"""Given a vector of assets, returns the asset table information for those assets."""
function getAssets(assets::Vector{<:Any};rowLimit=10000)
    table = "AeAAssetE"
    assetList = join(assets,",")
    crit = ["assetTag" => assetList]
    makeRequest(table,crit,header,rowLimit=rowLimit) |> parseResponse
end


"""Given a vector of asset numbers, returns the attribute fields and values for that asset"""
function getAssetAttributes(assets::Vector{<:Any};rowLimit=10000)
    #Get asset groups first    
    assetData = getAssets(assets,rowLimit=rowLimit)
    assetGroups = assetData.assetGroup |> unique
    assetGroupList = join(assetGroups,",")
    #Get attribute line details
    table = "AeAAstGrpAttr"
    crit = ["assetGroup" => assetGroupList]
    attrDetails = makeRequest(table,crit,header,rowLimit=rowLimit) |> parseResponse
    attrNames = select(attrDetails,[:assetGroup,:attrId,:label,:sequence])
    #attribute values
    table = "AeAAssetAttr"
    assetList = join(assets,",")
    crit = ["assetTag" => assetList]
    attrVals = makeRequest(table,crit,header,rowLimit=rowLimit) |> parseResponse
    #make tables for joins
    valTable = transform(attrVals,[:assetGroup,:attrId]=> ByRow((x,y)->string(x,y))=> :groupAttr)
    nameTable = transform(attrNames,[:assetGroup,:attrId]=> ByRow((x,y)->string(x,y))=> :groupAttr)
    joint = leftjoin(valTable,nameTable, on = :groupAttr, makeunique = true)
    assetTable = select(assetData,[:assetTag,:description,:bldg])
    joint2 = leftjoin(joint,assetTable, on = :assetTag) |>
        y-> select(y,[:assetTag,:description,:sequence,:attrId,:label,:attrValue]) |>
        y-> sort(y,[:assetTag,:sequence])
end