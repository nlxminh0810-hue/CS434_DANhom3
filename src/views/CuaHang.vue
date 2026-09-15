<template>
  <section class="shop">

    <aside class="filter-box">

      <h2>Bộ lọc</h2>

      <label>
        Danh mục

        <select v-model="category">
          <option value="">Tất cả</option>
          <option>Áo đấu</option>
          <option>Giày bóng đá</option>
          <option>Phụ kiện</option>
        </select>
      </label>

      <label>
        Giá tối đa

        <input
          v-model.number="maxPrice"
          type="range"
          min="100000"
          max="3000000"
          step="100000"
        >

        <span>
          {{ money(maxPrice) }}
        </span>

      </label>

    </aside>

    <div class="shop-content">

      <div class="title-row">

        <h2>Sản phẩm</h2>

        <span>
          {{ filteredProducts.length }} sản phẩm
        </span>

      </div>

      <div class="product-grid">

        <article
          v-for="item in filteredProducts"
          :key="item.id"
          class="product-card"
        >

          <div class="product-image-wrap">

            <img
              :src="item.image"
              class="product-image"
            >

          </div>

          <div class="product-info">

            <span class="product-category">
              {{ item.category }}
            </span>

            <h3>
              {{ item.name }}
            </h3>

            <p>
              {{ item.desc }}
            </p>

            <div class="price-row">

              <b>
                {{ money(item.price) }}
              </b>

              <small>
                Còn {{ item.stock }}
              </small>

            </div>

          </div>

          <div class="card-actions">

            <button
              class="secondary"
              @click="$emit('detail', item)"
            >
              Chi tiết
            </button>

            <button
              class="primary"
              @click="$emit('cart', item)"
            >
              Thêm giỏ
            </button>

          </div>

        </article>

      </div>

    </div>

  </section>
</template>

<script setup>
import { computed, ref } from 'vue'
import { money } from '../utils/format'

const props = defineProps({
  products: Array,
  keyword: String
})

defineEmits([
  'detail',
  'cart'
])

const category = ref('')
const maxPrice = ref(3000000)

const filteredProducts = computed(() => {

  const key =
    props.keyword.trim().toLowerCase()

  return props.products.filter((item) => {

    const text =
      `${item.name} ${item.category}`.toLowerCase()

    return (
      (!key || text.includes(key)) &&
      (!category.value || item.category === category.value) &&
      item.price <= maxPrice.value
    )
  })
})
</script>