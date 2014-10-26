require! <[node-trello fs]>

t = new node-trello "1c646bd5d51e2d7111f552b4729e8763"

cardPrefix = '### ---Code4hk Project Meta---'
hackpadPrefix = '\n- Hackpad';
githubPrefix = '\n- Github'
archievementPrefix = '\n- Product'
archievementWebPrefix = '\n- Web'


//TODO how to load this from project.ls instead? require failed//

projectTemplate =
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

//TODO some real list parsing logic like YAML//

parseMeta = (desc, prefix, isList) ->
  metaDesc = desc.substring (desc.indexOf prefix)
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

parseTrelloCard = (desc) ->
  start = desc.indexOf cardPrefix
  if start > -1
    desc .= substring start+ cardPrefix.length
    cardData = {}
    cardData.hackpadUrl = parseMeta desc,hackpadPrefix
    cardData.achievement = parseMeta desc,archievementPrefix,true
    cardData.githubUrl = parseMeta desc,githubPrefix
    json = [cardData2Project cardData] |> JSON.stringify
    fs.writeFile "project-list.json", json


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
  project ={} <<< projectTemplate
  if(data.hackpadUrl)
    project.workspace.push(getWorkspace data, "hackpad")
  if(data.githubUrl)
    project.workspace.push(getWorkspace data, "github")
  if (data.achievement)
    for achievement in data.achievement
      project.achievement.push({
          "type": "Web",
          "phase": "Production",
          "url": "https://www.facebook.com/umbrellagroupbuy"
      })
  project.id=1
  project.name.zh  = "團撐"
  project

transform = (data) ->
  for d in data
    d.desc |> parseTrelloCard



t.get "/1/boards/544b9e1d9825f631e01b5ede/cards" ((err,data) -> data |>transform)
