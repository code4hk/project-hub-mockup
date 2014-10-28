require! <[node-trello fs]>

t = new node-trello "1c646bd5d51e2d7111f552b4729e8763"

cardPrefix = '### ---Code4hk Project Meta---'
descPrefix = '\n- Desc';
hackpadPrefix = '\n- Hackpad';
githubPrefix = '\n- Github'
archievementPrefix = '\n- Product'
archievementWebPrefix = '\n- Web'



//TODO some real list parsing logic like YAML//

parseMeta = (desc, prefix, isList) ->
  prefixIndex = desc.indexOf prefix
  if prefixIndex > -1
    metaDesc = desc.substring (prefixIndex)
    if isList
       end = (metaDesc.indexOf '\n-', prefix.length)
       metaDesc = metaDesc.substring (metaDesc.indexOf '\n -' , prefix.length)+1, end
       metaData = [parseMeta metaDesc, archievementWebPrefix]
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
    cardData


printCards = (cards) ->
    data = for card in cards
      if card
        project = (cardData2Project card)
    data = data |> JSON.stringify
    console.log data
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
     org = githubRegex[1]
     repo = githubRegex[2]
     name = org + '/' + repo

  workspace = {
    "type":type,
    "name": name
    "url":data[type+'Url']
  }

  if workspace.url.indexOf('http') <0
    workspace.url = 'http://'+workspace.url
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
      project.achievement.push({
          "type": "Web",
          "phase": "Production",
          "url": achievement
      })
  project.name.zh  = data.name
  project.intro.zh.short = data.desc ? data.desc : ''
  project

transform = (data) ->
  cards = for d in data
            d |> parseTrelloCard
  printCards cards



t.get "/1/boards/544b9e1d9825f631e01b5ede/cards" ((err,data) -> data |>transform)
