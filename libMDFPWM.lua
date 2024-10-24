-- MDFPWMv3 file format reader
-- Code by Drucifer@SwitchCraft.kst
-- Consider donating?
-- Last updated: 2/12/2024
-- Update to include .meta table returned with parse, .getSample remains unchanged

local string,math=_G.string,_G.math

-- Main functions
--Usage .parse(fs.open("disk/song.mdfpwm","rb"))
--Returns table with single function .getSample(sec) and meta table .meta={title,artist,album}
local function parse(handle)
  if not handle or type(handle) ~= "table" or not handle.read then return false,"Incorrect handle provided" end
  if handle.read(7) == "MDFPWM\003" then
    local datalen,artist,title,album,headerlen=string.unpack("<Is1s1s1",handle.read(772))
    local sampleCount=math.ceil(datalen/12000)
    handle.seek("set",7+headerlen-1)
    local dataStream=handle.read(sampleCount*12000)
	-- Usage .getSample(sec)
	-- Returns: One second of buffer from both channels indicated by seconds (starting at 1) {left=<6000 bytes DFPWM>,right=<6000 bytes DFPWM>}
    local function getSample(iNum)
      if iNum < 1 or iNum > sampleCount then return nil end
      local sampleData=dataStream:sub(1+((iNum-1)*12000),iNum*12000)
      return {left=sampleData:sub(1,6000),right=sampleData:sub(6001,12000)}
    end
    return {getSample=getSample,meta={len=sampleCount,artist=artist,title=title,album=album}}
  else
    return false,"MDFPWMv3 header not found"
  end
end

--Usage .meta(fs.open("disk/song.mdfpwm","rb"))
--Returns table containing the metadata of the track {len:int(seconds),artist:string,title:string,album:string}
local function meta(handle)
  local isMDFPWM,currpos,peekData=false,handle.seek(),{}
  if handle.read(7) == "MDFPWM\003" then
    isMDFPWM=true
    peekData.len,peekData.artist,peekData.title,peekData.album=string.unpack("<Is1s1s1",handle.read(772))
    peekData.len=math.ceil(peekData.len/12000)
  end handle.seek("set",currpos)
  return isMDFPWM and peekData or {false,"Not MDFPWMv3 Formatted"}
end

return {parse=parse,read=parse,meta=meta}
