--Metronome

FreeAllRegions()

dofile(SystemPath("urHelpers.lua"))
--Req("urWidget")



local function ShutdownAudio()
    dac:RemovePullLink(0, upSample, 0)
end

local function ReInit(self)
    dac:SetPullLink(0, upSample, 0)
end

-- Instantiating background
background = MakeRegion({
        w=ScreenWidth(), 
        h=ScreenHeight(), 
        layer='BACKGROUND', 
        x=0,y=0, img="PongBG.png"
    })
background:Handle("OnPageEntered", ReInit)
background:Handle("OnPageLeft", ShutdownAudio)

beatsPerMin = 70
FramesPerSec = 50
SetFrameRate(1/50) --50 Hz

function Click()
    if count == 0 then
        updatesPerBeat = 60/beatsPerMin*FramesPerSec
    end
    count = count+1
    if count >= updatesPerBeat-1 then
        upPush:Push(0.0)
        DPrint(Time())
        count = 0
    end   
    
    --[[local thisStartTime = Time()
    if not betweenBeats then
    secsPerBeat = 60/beatsPerMin
    startTime = thisStartTime
    DPrint(startTime)
end

repeat
    if Time()-thisStartTime > secPerUpdate then
    betweenBeats = true
    return
end
until Time()-startTime > secsPerBeat

--if math.random() > 0 then
upPush:Push(0.0)
betweenBeats = false
--end
--]]
end

tempoBox = MakeRegion({w=100, h=80, layer='TOOLTIP', x=ScreenWidth()/2-100/2, y=ScreenHeight()/2})
        --label={color={0,0,60,190}, size=48, align='CENTER', text=beatsPerMin}})
tempoBox.label = tempoBox:TextLabel()
tempoBox.label:SetFont("Trebuchet MS")
tempoBox.label:SetHorizontalAlign("CENTER")
tempoBox.label:SetLabelHeight(48)
tempoBox.label:SetColor(0,0,60,190)
tempoBox.label:SetLabel(beatsPerMin)

tempoUp = MakeRegion({w=80, h=80, layer='TOOLTIP', x=0, y=ScreenHeight()/2, color='blue', input=true})
tempoDown = MakeRegion({w=80, h=80, layer='TOOLTIP', x=ScreenWidth()-80, y=ScreenHeight()/2,
        color='yellow', input=true})        

tempoUp:Handle("OnTouchDown", increaseTempo)
tempoDown:Handle("OnTouchDown", decreaseTempo)

function resetTempoDisplay()
    tempoBox.label:SetLabel(beatsPerMin)
end

function increaseTempo()
    beatsPerMin = beatsPerMin+1
    DPrint(beatsPerMin)
    resetTempoDisplay()
end

function decreaseTempo()
    beatsPerMin = beatsPerMin-1
    DPrint(beatsPerMin)
    resetTempoDisplay()
end

startButton = MakeRegion({w=75, h=75, layer='TOOLTIP', x=60, y=100, color='green', input=true})
stopButton = MakeRegion({w=75, h=75, layer='TOOLTIP', x=185, y=100, color='red', input=true})

startButton:Handle("OnTouchDown", startAudio)
stopButton:Handle("OnTouchDown", stopAudio)

function startAudio()
    SetAttrs(startButton,{color = 'lightgreen'})
    
    dac:SetPullLink(0, upSample, 0)
    
    --betweenBeats = false
    count = 0
    startButton:Handle("OnUpdate",Click)
    
end

function stopAudio()
    startButton:Handle("OnUpdate",nil)
    SetAttrs(startButton,{color = 'green'})
    ShutdownAudio()
end

pagebutton = MakeRegion({w=16,h=16,
    layer='TOOLTIP',
    x=ScreenWidth()-28, y=ScreenHeight()-28,
    img="circlebutton-16.png",
    input=true
})
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)


dac = _G["FBDac"]
upSample = FlowBox("object","mysample2", FBSample)
upSample:AddFile("Plick.wav")

upPush = FlowBox("object", "mypush", FBPush)

    upPush:SetPushLink(0,upSample, 4)  
    upPush:Push(-1.0); -- Turn looping off
    upPush:RemovePushLink(0,upSample, 4)  
    upPush:SetPushLink(0,upSample, 2)
    upPush:Push(1.0); -- Set position to end so nothing plays.
