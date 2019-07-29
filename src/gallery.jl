
const global_style = "position: absolute; top: 0px; left: 0px; visibility: visible; will-change: transform; opacity: 1; transform: translate(525px, 1220px) scale(1); transition-duration: 250ms; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-property: transform, opacity;"

struct MediaItem
  title::String
  media::String
  preview::String
  link::String
  tags::Vector{String}
end

function master_url(root, path)
    urlbase = "http://juliaplots.org/MakieReferenceImages/gallery/"
    if Sys.iswindows()
        path = replace(path, "\\" => "/")
        root = replace(root, "\\" => "/")
    end
    url = replace(
        path,
        root => urlbase
    )
end

function MediaItem(path, example)
    media_file = ""
    media_folder = joinpath(path, "media")
    files = readdir(media_folder)
    for ext in ("mp4", "gif", "jpg", "png")
        idx = findfirst(x-> endswith(x, ext), files)
        if idx !== nothing
            media_file = joinpath(media_folder, files[idx])
            break
        end
    end
    if isempty(media_file)
        error("No media for $(example.title)")
    end
    root = dirname(path)
    MediaItem(
        example.title,
        embed_media(master_url(root, media_file)),
        "",
        master_url(root, joinpath(path, "index.html")),
        string.(example.tags)
    )
end

function create_item(item::MediaItem; style = global_style)
    create_item(item.title, item.media, item.preview, item.link, item.tags; style = style)
end

function create_item(title, media, preview, link, tags; style = global_style)
  """
  <figure class="col-3@xs col-4@sm col-3@md picture-item shuffle-item shuffle-item--visible" data-groups='$(repr(tags))' data-date-created="2017-04-30" data-title=$(repr(title)) style=$(repr(style))>
    <div class="picture-item__inner">
      <div class="aspect aspect--16x9">
        <div class="aspect__inner">
          $(media)
          <img class="picture-item__blur" src=$(repr(preview)) alt="" aria-hidden="true">
        </div>
      </div>
      <div class="picture-item__details">
        <figcaption class="picture-item__title"><a href=$(repr(link)) target="_blank" rel="noopener">$(repr(title))</a></figcaption>
        <p class="picture-item__tags hidden@xs"></p>
      </div>
    </div>
  </figure>
  """
end



function create_page(
    items, tags;
    shufflejs = "https://cdnjs.cloudflare.com/ajax/libs/Shuffle/5.2.0/shuffle.min.js"
  )
  tag_buttons = join(map(tags) do tag
    """<button class="btn btn--primary" data-group=$(repr(tag))>$tag</button>"""
  end, "\n")
  groups = join(create_item.(items), "\n")
  html_groups = """
  <script src="$shufflejs"></script>
  <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://rawgit.com/Vestride/Shuffle/master/docs/css/prism.css">
  <link rel="stylesheet" href="https://rawgit.com/Vestride/Shuffle/master/docs/css/normalize.css">
  <link rel="stylesheet" href="https://rawgit.com/Vestride/Shuffle/master/docs/css/style.css">
  <link rel="stylesheet" href="https://rawgit.com/Vestride/Shuffle/master/docs/css/shuffle-styles.css">
    <div class="container">
      <div class="row">
        <div class="col-12@sm">
          <h2>Example<a href="#demo"></a></h2>
        </div>
      </div>
    </div>
    <div class="container">
      <div class="row">
        <div class="col-4@sm col-3@md">
          <div class="filters-group">
            <label for="filters-search-input" class="filter-label">Search</label>
            <input class="textfield filter__search js-shuffle-search" type="search" id="filters-search-input">
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-12@sm filters-group-wrap">
          <div class="filters-group">
            <p class="filter-label">Filter</p>
            <div class="btn-group filter-options">
              $(tag_buttons)
            </div>
          </div>
          <fieldset class="filters-group">
            <legend class="filter-label">Sort</legend>
            <div class="btn-group sort-options">
              <label class="btn active">
                <input type="radio" name="sort-value" value="dom"> Default
              </label>
              <label class="btn">
                <input type="radio" name="sort-value" value="title"> Title
              </label>
              <label class="btn">
                <input type="radio" name="sort-value" value="date-created"> Date Created
              </label>
            </div>
          </fieldset>
        </div>
      </div>
    </div>
    <div class="container">
      <div id="grid" class="row my-shuffle-container shuffle" style="height: 1220px; transition: height 250ms cubic-bezier(0.4, 0, 0.2, 1) 0s;">
        $groups
        <div class="col-1@sm col-1@xs my-sizer-element"></div>
      </div>
    </div>
  """
  js_script = read(joinpath(@__DIR__, "gallery.js"), String)
  return """
  <!doctype html>
  <html>
    <head>
      <meta charset="UTF-8">
    </head>
    <body>
      $html_groups
      <script>
      $js_script
      </script>
    </body>
  </html>
  """
end
