<style>
    body {
        background-color: lightgrey;
    }


    .editor-row {
        padding: 10px ;
        border-left: 1px solid black;
        border-right: 1px solid black;
        border-bottom: 1px solid black ;
    }

    .editor-row:last-child {
        border-bottom: 0  solid black ;
         /*background-color: dodgerblue;*/
     }
    .expand-button {
        height: 1.5em;
        margin: 10px;
    }

    .sticky-search-panel {
        border-bottom: 1px solid black;
        background-color: lightgrey;
        padding: 10px ;
    }
</style>
<template>
    <div class="container-fluid">
        <div v-if="!account.authenticated">
            <div class="row mt-4">
                <div class="col-2"></div>
                <div class="col-8">
                    <Login @authentication-attempt="afterAuthentication"/>
                </div>
                <div class="col-2"></div>
            </div>
        </div>
        <div v-if="account.authenticated">
            <StickyTopBox
                    @show-collapse-button="showCollapseButtonCallback"
                    @show-expand-button="showExpandButtonCallback"
                    class="sticky-search-panel">

                <template v-slot:fixed-top>
                    <div class="row">
                        <div class="col-3 mt-4"></div>
                        <div class="col-6 mt-4 text-center ">
                            <span style="font-weight: bold">{{count}}</span> results
                        </div>
                        <div class="col-3 mt-4 text-right">
                            <a class="text-right" href="#" @click.prevent="logout">Logout</a>
                        </div>
                    </div>
                </template>

                <template v-slot:expanded>

                    <div class="row">
                        <div class="col-12">
                            <Search
                                    @search-parameters-cleared="searchParametersCleared"
                                    @search-parameters-changed="searchParametersChanged"
                                    :query="search.query"
                                    :start="search.start"
                                    :stop="search.stop"
                                    :errors="search.errors"
                            />
                        </div>

                    </div>

                </template>

                <template v-slot:fixed-bottom>
                    <div class="row">
                        <div class="col-12 text-center">
                            <a href="#" v-if="showExpandButton" @click.prevent="toggleSearch">
                                <img alt="Expand Search Panel" class="expand-button" src="/plus.png"/>
                            </a>
                            <a href="#" v-if="showCollapseButton" @click.prevent="toggleSearch">
                                <img alt="Collapse Search Panel" class="expand-button" src="/minus.png"/>
                            </a>
                        </div>
                    </div>
                </template>

            </StickyTopBox>
            <div class="row">
                <div class="col-12 editor-rows">
                    <div v-for="bookmark in bookmarks"
                         class="editor-row"
                         :key="bookmark.bookmarkId">
                        <Editor @save-bookmark="saveBookmark"
                                @open-bookmark="openBookmark"
                                @delete-bookmark="deleteBookmark"
                                :bookmark="bookmark"/>
                    </div>
                </div>
            </div>
        </div>


    </div>
</template>
<script>

  import Editor from "./components/bookmarks/Editor"
  import Search from "./components/bookmarks/Search"
  import Login from "./components/Login"
  import SearchQuery from "./SearchQuery"
  import LoginService from "./LoginService"
  import BookmarkService from "./BookmarkService"
  import StickyTopBox from "./components/util/StickyTopBox";

  const rootUrl = ((u) => (u.endsWith('/')) ? u : u + '/')(process.env.VUE_APP_SERVICE_ROOT)
  const loginService = new LoginService(rootUrl + 'token')
  const bookmarkService = new BookmarkService(rootUrl)

  export default {
    name: 'App',
    mounted() {
    },
    created() {

      this.$root.log = function () {// useful for logging reactive properties
        for (let i = 0; i < arguments.length; i += 1) {
          if (typeof (arguments[i]) === 'object') {
            try {
              arguments[i] = JSON.parse(JSON.stringify(arguments[i]))
            } catch (e) {
              console.error(e)
            }
          }
        }
        console.log(...arguments)
      }

      this.$on('logout', () => {
        this.account.authenticated = false
      })

      this.$on('authentication-success', user => {
        bookmarkService
          .setAuthentication(user)
          .then(() => {
            this.account.authenticated = true
          })
          .then(() => {
            // if we're authenticated then force the loading of
            // the last two weeks' worth of results
            this.searchParametersChanged(this.search)
          })
      })

      loginService
        .attemptLogin()
        .then(user => {
          this.$emit("authentication-success", user)
        })
        .catch(() => {
          console.error('No valid JWT token found or authentication failed. ' +
            'You will need to authenticate manually.')
        })

    },
    methods: {
      toggleExpand() {
        this.expandButtonToggleFunction()
      },
      resetExpandCollapse(callback) {
        this.showExpandButton = false
        this.showCollapseButton = false
        this.expandButtonToggleFunction = callback
      },
      showCollapseButtonCallback(callback) {
        this.resetExpandCollapse(callback)
        this.showCollapseButton = true
      },
      showExpandButtonCallback(callback) {
        this.resetExpandCollapse(callback)
        this.showExpandButton = true
      },
      toggleSearch() {
        this.showSearch = !this.showSearch
        this.expandButtonToggleFunction()
      },
      afterAuthentication(authentication) {
        loginService
          .login(authentication.username, authentication.password)
          .then(user => {
            this.$emit("authentication-success", user)
          })
          .catch((exception) => {
            console.error(`could not login: ${exception.toString()} `)
          })
      },
      logout() {
        loginService
          .logout()
          .then(() => {
            const dateOfLogout = Date.now()
            if (this.debug) {
              console.log('logging out @ ' + dateOfLogout)
            }
            this.$emit("logout", {when: dateOfLogout})
          })
      },
      searchParametersCleared() {
        this.loadBookmarks([])
      },
      searchParametersChanged(search) {
        this.search = search
        if (this.debug === true) {
          console.log('the search has changed', JSON.stringify(this.search))
        }

        bookmarkService
          .search(this.search)
          .then(json => this.loadBookmarks(json))
          .catch(() => {
            this.logout()
          })
      },
      openBookmark(bookmark) {
        window.open(bookmark.href, 'ttd_window')
      },
      deleteBookmark(bookmark) {
        bookmarkService
          .delete(bookmark.bookmarkId)
          .then(() => {
            this.searchParametersChanged(this.search)
          })
          .catch(() => {
            this.logout()
          })
      },
      saveBookmark(bookmark) {
        bookmarkService
          .save(bookmark)
          .then(() => {
            this.searchParametersChanged(this.search)
          })
          .catch(() => {
            this.logout()
          })
      },
      showExpandButton() {

      },
      showCollapseButton() {

      },
      loadBookmarks: function (bookmarks) {
        bookmarks = bookmarks.map((bookmark) => {
          bookmark.time = (bookmark.time * 1000)
          return bookmark
        })

        bookmarks.sort((a, b) => {
          /* a record has errors if edited === null */
          const aHasEdited = a.edited === null
          const bHasEdited = b.edited === null
          if (aHasEdited) {
            return -1
          }
          if (bHasEdited) {
            return 1
          }
          return 0
        })

        this.$nextTick(() => {
          this.bookmarks = bookmarks
          this.count = this.bookmarks.length
        })
      }
    },
    data() {

      function oneWeekAgo(now) {
        const minute = 1000 * 60
        const hour = minute * 60
        const day = 24 * hour
        const week = day * 7
        return new Date(now - week)
      }

      const today = new Date()
      const twoWeeksAgo = oneWeekAgo(oneWeekAgo(today))

      return {
        showSearchExpand: false,
        count: 0,
        showSearch: true,
        account: {
          authenticated: false
        },
        search: new SearchQuery(null, false, twoWeeksAgo, today),
        debug: false,
        bookmarks: []
      }
    },
    components: {
      StickyTopBox,
      Search,
      Login,
      Editor
    }
  }
</script>
