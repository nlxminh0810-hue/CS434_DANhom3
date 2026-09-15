<template>
  <section class="detail-box">

    <img :src="product.image" class="detail-image">

    <div>

      <p class="label">
        {{ product.category }}
      </p>

      <h2>
        {{ product.name }}
      </h2>

      <strong class="detail-price">
        {{ money(product.price) }}
      </strong>

      <p>
        {{ product.desc }}
        Sản phẩm phù hợp luyện tập
        và thi đấu phong trào.
      </p>

      <div class="option-line">

        <span>Màu sắc</span>

        <button v-for="color in colors" :key="color" :class="{ picked: order.color === color }"
          @click="order.color = color">
          {{ color }}
        </button>

      </div>

      <div class="option-line">

        <span>Size</span>

        <button v-for="size in sizes" :key="size" :class="{ picked: order.size === size }" @click="order.size = size">
          {{ size }}
        </button>

      </div>

      <div class="qty">

        <button @click="order.qty = Math.max(1, order.qty - 1)">
          -
        </button>

        <input v-model.number="order.qty" type="number" min="1">

        <button @click="order.qty++">
          +
        </button>

      </div>

      <div class="actions">

        <button class="secondary" @click="$emit('cart', product, order)">
          Thêm vào giỏ hàng
        </button>

        <button class="primary" @click="$emit('buy', product, order)">
          Đặt hàng
        </button>

      </div>
    </div>
  </section>
</template>

<script setup>
import { reactive } from 'vue'
import { money } from '../utils/format'

defineProps({
  product: Object
})

defineEmits([
  'cart',
  'buy'
])

const colors = [
  'Xanh',
  'Đỏ',
  'Tím',
  'Vàng'
]

const sizes = [
  'M',
  'L',
  'XL',
  'XXL'
]

const order = reactive({
  color: 'Xanh',
  size: 'M',
  qty: 1
})
</script>