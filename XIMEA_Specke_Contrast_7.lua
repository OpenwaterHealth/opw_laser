--[[
When this script is executed the exposure time is set to 10ms and the image
acquisition is started. Some properties of the 10 acquired images will be
printed
--]]

-- Retrieve an object representing the camera
print("Opening first camera...")
local cam = cameras.Get()

-- Setting "exposure" parameter (10ms=10000us)
cam:SetParam(XI_PRM_EXPOSURE, 10000)
cam:SetParam(XI_PRM_GAIN, 0)
-- cam:SetParam(XI_PRM_AEAG, XI_OFF)
-- cam:SetParam(XI_PRM_OFFSET_X, 1032)
-- cam:SetParam(XI_PRM_OFFSET_Y, 752)
-- cam:SetParam(XI_PRM_WIDTH, 2056)
-- cam:SetParam(XI_PRM_HEIGHT, 1504)
-- cam:SetParam(XI_PRM_REGION_SELECTOR, 0)
-- cam:SetParam(XI_PRM_REGION_MODE, 0)

-- cam:SetParam(XI_PRM_GPI_SELECTOR, XI_GPI_PORT1)
-- cam:SetParam(XI_PRM_GPI_MODE, XI_GPI_TRIGGER)

cam:SetParam(XI_PRM_HDR, XI_OFF)
cam:SetParam(XI_PRM_FFC, XI_OFF)
 
cam:SetParam(XI_PRM_GAMMAY, 1)
cam:SetParam(XI_PRM_GAMMAC, 1)

-- cam:SetParam(XI_PRM_TRG_SOURCE, XI_TRG_EDGE_RISING)
-- cam:SetParam(XI_PRM_TRG_SELECTOR, XI_TRG_SEL_FRAME_START)
-- cam:SetParam(XI_PRM_TRG_DELAY, 50000)



-- Start the image acquisition and show in view
local viewId = cam:StartAcquisition()

-- Measure dark level
app.WaitForNextFrame(1, viewId)
local img0 = app.GetViewImage(viewId)

local N = 30  -- number of images for background calculations
for i=0, N do
  -- Copy image from view
  app.WaitForNextFrame(1, viewId)
  local img = app.GetViewImage(viewId)
  img0:Add(img)
  local table = img:MeasureRect(rawIsMono)
  print(i.." Mean: "..table[1].mean.." STD: "..table[1].stdev)
  
end
img0:DivideByValue(N+2)
local table = img0:MeasureRect(rawIsMono)
print("S Mean: "..table[1].mean.." STD: "..table[1].stdev)
viewId0 = app.NewViewWithImage(img0)


app.MessageBox("Background acquired", "Continue", "OK")
--app.ActivateView(viewId)

local CView = graph.CreateNew()
local SeriesN = CView:AddSeries()

app.ActivateView(viewId)

app.WaitForNextFrame(1, viewId)
local img = app.GetViewImage(viewId)
local timestamp0 = img:GetTimeStamp()
print("N,Time,Mean,STD,Contr:")

for i=0, 500 do  -- number of images with light
  -- Copy image from view
  app.WaitForNextFrame(1, viewId)
  local img = app.GetViewImage(viewId)
  local timestamp = img:GetTimeStamp() - timestamp0
  img:Subtract(img0)

  -- Get first pixel and size of the image
  -- local pixel = img:GetPixelValue(1,1)
  -- local width = img:GetWidth()
  -- local height = img:GetHeight()
  local table = img:MeasureRect(rawIsMono)
  -- if table[1].mean < 1 then break end

  -- print("Image "..i.." ("..width.."x"..height..") received from camera.")
  -- print("First pixel value: "..pixel)
  print(i..","..timestamp..","..table[1].mean..","..table[1].stdev..","..table[1].stdev/table[1].mean)
  app.ShowNotification(i.."\n Contr: "..table[1].stdev/table[1].mean.."\n Time: "..timestamp.."\n Mean: "..table[1].mean.."\n STD: "..table[1].stdev)
  CView:SeriesAddPoint(SeriesN, timestamp, table[1].stdev/table[1].mean)
  

end -- for 0 to 500

print("Stopping acquisition...")
cam:StopAcquisition()

img2 = image.CreateNew(1200, 800, 3, 8)
CView:DrawIntoImage(img2)
app.NewViewWithImage(img2,"Contrast")  -- graph is displayed in new image
CView:CopySeriesDataToClipboard(SeriesN) -- data is copied to clipboard when script finished

print("Done")