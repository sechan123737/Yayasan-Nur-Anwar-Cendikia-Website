<script setup>
import { ref } from 'vue'

const amounts = [50000, 100000, 250000, 500000, 1000000]
const selected = ref(100000)
const showFeedback = ref(false)

function donate() {
  showFeedback.value = true
}

function formatRupiah(n) {
  return n.toLocaleString('id-ID')
}
</script>

<template>
  <section id="donate" class="py-16 bg-white scroll-mt-20">
    <div class="max-w-7xl mx-auto px-6">
      <div class="relative overflow-hidden rounded-3xl gradient-overlay pattern-bg p-12 md:p-16 text-center text-white">
        <h2 class="font-display text-3xl md:text-5xl font-bold mb-4">Buat Perbedaan Hari Ini</h2>
        <p class="text-white/80 text-lg max-w-xl mx-auto mb-10">Kemurahhatian Anda mengubah kehidupan. Setiap donasi membantu kami menyediakan pendidikan, nutrisi, dan harapan untuk anak-anak yang membutuhkan.</p>

        <div class="flex flex-wrap justify-center gap-4 mb-10">
          <button
            v-for="amt in amounts"
            :key="amt"
            @click="selected = amt; showFeedback = false"
            class="px-8 py-3 rounded-full font-semibold transition-all"
            :class="selected === amt
              ? 'bg-white text-forest shadow-lg'
              : 'bg-white/20 border-2 border-white/40 text-white hover:bg-white hover:text-forest'"
          >
            Rp {{ amt >= 1000000 ? (amt / 1000000) + 'M' : (amt / 1000) + 'K' }}
          </button>
        </div>

        <div v-if="showFeedback" class="mb-6 bg-white/20 backdrop-blur-sm rounded-xl p-4 max-w-md mx-auto">
          <p class="text-white font-medium">Terima kasih! Donasi Anda sebesar Rp {{ formatRupiah(selected) }} akan mengubah kehidupan. 💚</p>
        </div>

        <button @click="donate" class="bg-gold text-white px-10 py-4 rounded-full font-bold text-lg hover:bg-yellow-500 transition-all shadow-xl hover:shadow-2xl">
          Donasi Sekarang
        </button>
        <p class="text-white/50 text-xs mt-4">100% dari donasi Anda langsung untuk program kami</p>
      </div>
    </div>
  </section>
</template>
