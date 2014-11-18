require! <[node-trello fs]>
require! '../config'
//TODO externalize token//
t = new node-trello config.trello.token

cardPrefix = '### ---Code4hk Project Meta---'
descPrefix = '\n- Desc';
hackpadPrefix = '\n- Hackpad';
githubPrefix = '\n- Github'
archievementPrefix = '\n- Product'
archievementWebPrefix = '- Web'
archievementAndroidPrefix = '- Android'
tagPrefix = '\n- Tag'

ensureUrlWork = (url)->
  if url.indexOf('http') <0
    return 'http://'+url
  return url


//TODO some real list parsing logic like YAML//

parseMeta = (desc, prefix, isList) ->
  prefixIndex = desc.indexOf prefix
  if prefixIndex > -1
    metaDesc = desc.substring (prefixIndex)
    if isList
       end = (metaDesc.indexOf '\n-', prefix.length)
       metaDesc = metaDesc.substring (metaDesc.indexOf '\n -' , prefix.length)+2, end
       web = parseMeta metaDesc, archievementWebPrefix
       android = parseMeta metaDesc, archievementAndroidPrefix
       metaData = []
       phase = 'Production'
       if web
         console.log web
         if (web.indexOf '[mockup]') >-1
           console.log 'isMock' +web.indexOf '[mockup]'
           phase = 'Mockup'
         metaData.push {
           'type':'web',
           'phase':phase,
           'url':web
         }
       if android
         metaData.push {
           'type':'android',
           'phase':phase,
           'url':android
         }
    else
       end =  (metaDesc.indexOf '\n', prefix.length)
       if end === -1
         metaData = metaDesc.substring prefix.length+2
       else
         metaData = metaDesc.substring prefix.length+2, end
  metaData

parseTrelloCard = (data) ->
  name = data.name
  desc = data.desc
  labels = data.labels
  start = desc.indexOf cardPrefix
  if start > -1
    desc .= substring start+ cardPrefix.length
    cardData = {}
    cardData.name = name;
    cardData.desc = parseMeta desc, descPrefix
    if typeof cardData.desc !== 'string'
      cardData.desc =''
    cardData.hackpadUrl = parseMeta desc,hackpadPrefix
    cardData.achievement = parseMeta desc,archievementPrefix,true
    cardData.githubUrl = parseMeta desc,githubPrefix
    if data.idList === "544b9e262dfa51c43a0ace04"
       cardData.list = "hackathon"
    tagString = (parseMeta desc, tagPrefix)
    tags = []
    if tagString
      tags = tagString.split(" ")
    cardData.labels = labels;
    cardData


printCards = (cards) ->
    data = for card in cards
      if card
        project = (cardData2Project card)
    data = data |> JSON.stringify
    fs.writeFile __dirname+"/project-list.json", data


/*"achievement": [
  {
    "type": "Web",
    "phase": "Production",
    "url": "https://www.facebook.com/umbrellagroupbuy"
  }
],*/

getWorkspace = (data, type,name) ->
  name = if name
         then name
         else type

  if type === 'github'
     githubRegex = /.*www.github.com\/([^\/]*)\/([^\/]*)/ is data[type+'Url']
     if githubRegex
       org = githubRegex[1]
       repo = githubRegex[2]
       name = org + '/' + repo

  workspace = {
    "type":type,
    "name": name
    "url":data[type+'Url']
  }

  workspace.url = ensureUrlWork workspace.url
  workspace


cardData2Project = (data) ->
  //TODO how to load this from project.ls instead? require failed//
  //Also failed to clone by livescript using {}<<//
  project =
    * id: ""
      "name":
        zh: ""
        en: ""
      logo: ""
      intro:
        zh:
          short: ""
          medium: ""
          long: ""
        en:
          short: ""
          medium: ""
          long: ""
      category: <[]>
      tag: <[]>
      participant: {}
      tool:
        * ""
          ""
      license:
        * ""
          ""
      homepage: ""
      achievement:
        []
      workspace:
        []
      resource:
        []
      follower: <[]>
      story:
        [{
          title: ""
          "url": ""
        }]
      related: <[]>

  if(data.hackpadUrl)
    project.workspace.push(getWorkspace data, "hackpad")
  if(data.githubUrl)
    project.workspace.push(getWorkspace data, "github")
  if (data.achievement)
    for achievement in data.achievement
      achievement.url = ensureUrlWork achievement.url
      project.achievement.push(achievement)
  project.name.zh  = data.name
  project.intro.zh.short = data.desc ? data.desc : ''
  if (data.list === "hackathon")
     project.category.push("hackathon")
  for label in data.labels
    if label.name === 'Helper Wanted'
      project.needHelp = true
  console.log project
  project

transform = (data) ->
  cards = for d in data
            d |> parseTrelloCard
  printCards cards

//TODO Logic to map particular list into category//


t.get "/1/boards/544b9e1d9825f631e01b5ede/cards" ((err,data) -> data |>transform)
