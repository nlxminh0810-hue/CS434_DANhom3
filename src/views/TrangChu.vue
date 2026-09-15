<template>
  <section class="hero">
    <div class="hero-left">
      <p class="label">
        Nền tảng thương mại điện tử bóng đá
      </p>

      <h1>SoccerHub</h1>

      <p class="intro">
        Mua giày, áo đấu và phụ kiện bóng đá.
        Hệ thống có đăng nhập, giỏ hàng,
        quản trị sản phẩm và thống kê.
      </p>

      <div class="actions">
        <button
          class="primary"
          @click="$emit('navigate','shop')"
        >
          Xem sản phẩm
        </button>

      </div>
    </div>

    <div class="hero-card">
      <article
        v-for="item in products.slice(0,4)"
        :key="item.id"
        class="mini-card"
        role="button"
        tabindex="0"
        @click="$emit('navigate','shop')"
        @keydown.enter="$emit('navigate','shop')"
        @keydown.space.prevent="$emit('navigate','shop')"
      >
        <img
          :src="item.image"
          class="mini-image"
        >

        <div class="mini-content">
          <span>{{ item.category }}</span>

          <b>{{ item.name }}</b>

          <p>{{ money(item.price) }}</p>
        </div>
      </article>
    </div>
  </section>
</template>

<script setup>
import { money } from '../utils/format'

defineProps({
  products:Array
})

defineEmits(['navigate'])
</script>
