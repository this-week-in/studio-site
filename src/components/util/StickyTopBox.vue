<template>

    <div class="sticky-top">
        <slot name="fixed-top"></slot>
        <div v-if="!expanded">
            <slot name="collapsed"></slot>
        </div>
        <div v-if="expanded">
            <slot name="expanded"></slot>
        </div>
        <slot name="fixed-bottom">
        </slot>
    </div>
</template>
<script>
  export default {
    name: 'StickyTopBox',
    created() {

      // RULES:
      // 1. when we're at 0, expand, no matter what
      // 2. when we're beyond 0, collapse
      // 3. if we're beyond 0, and somebody forceExpands,
      //    then we want to stay expanded no matter what


      setInterval(() => {
        this.$nextTick(() => {
          const that = this

          function captureState() {
            return that.showToggle + ':' + that.expanded
          }

          const oldState = captureState()

          if (window.scrollY === 0) {
            this.expanded = true
            this.showToggle = true
          }
          if (window.scrollY > 0) {
            this.expanded = this.forceExpand
            this.showToggle = true
          }

          const newState = captureState()
          const callback = () => {
            that.toggle()
          }
          if (newState !== oldState) {
            // the old state is different so lets emit events to trigger UI changes
            if (this.showToggle) {
              if (!this.expanded) {
                this.$emit('show-expand-button', callback)
              } else {
                this.$emit('show-collapse-button', callback)
              }
            }
          }
        })
      }, 100)
    },
    data() {
      return {
        showToggle: false,
        forceExpand: false,
        expanded: true
      }
    },
    methods: {
      toggle() {
        this.forceExpand = !this.forceExpand
      }
    }
  };
</script>