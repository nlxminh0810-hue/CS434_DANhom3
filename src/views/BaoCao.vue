<template>
  <section class="panel report-panel">

    <h2>Thống Kê Báo Cáo</h2>

    <div class="admin-summary">

      <article>
        <b>{{ money(revenue) }}</b>
        <span>Tổng doanh thu</span>
      </article>

      <article>
        <b>{{ orders.length }}</b>
        <span>Tổng đơn hàng</span>
      </article>

      <article>
        <b>{{ products.length }}</b>
        <span>Mặt hàng</span>
      </article>

      <article>
        <b>{{ topProduct?.name }}</b>
        <span>Top sản phẩm</span>
      </article>

    </div>

    <div class="report-grid">

      <div class="chart-card">

        <h3>
          Biểu Đồ Thống Kê Doanh Thu
        </h3>

        <div class="line-chart">

          <svg viewBox="0 0 400 200">

            <polyline
              fill="none"
              stroke="#67e8f9"
              stroke-width="5"
              points="
                20,150
                90,110
                160,120
                240,50
                320,40
              "
            />

          </svg>

        </div>

      </div>

      <div class="chart-card">

        <h3>
          Biểu Đồ Thống Kê Mặt Hàng
        </h3>

        <div class="pie-chart"></div>

      </div>

    </div>

  </section>
</template>

<script setup>
import { computed } from 'vue'
import { money } from '../utils/format'

const props = defineProps({
  orders:Array,
  products:Array
})

const revenue = computed(() =>
  props.orders.reduce(
    (sum,item)=>sum + item.total,
    0
  )
)

const topProduct = computed(() =>
  [...props.products]
    .sort((a,b)=>b.price-a.price)[0]
)
</script> 