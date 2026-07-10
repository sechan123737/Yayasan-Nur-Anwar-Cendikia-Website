<script setup>
import { useAuth } from '../composables/useAuth'

const { isLoggedIn } = useAuth()

const benefits = [
  { icon: '/images/Akses Penuh.png', title: 'Akses Penuh', desc: 'Baca detail lengkap setiap program: laporan, cerita penerima manfaat, dan progres terbaru.' },
  { icon: '/images/Update Rutin.png', title: 'Update Rutin', desc: 'Dapatkan kabar terbaru seputar kegiatan dan dampak program yang kamu dukung.' },
  { icon: '/images/Peluang Terlibat.png', title: 'Peluang Terlibat', desc: 'Jadi yang pertama tahu soal kesempatan menjadi relawan, donatur, atau mitra program.' }
]
</script>

<template>
  <section id="volunteer" class="py-24 bg-cream scroll-mt-20">
    <div class="max-w-7xl mx-auto px-6">
      <div class="text-center mb-16">
        <p class="text-leaf font-semibold tracking-widest uppercase text-sm mb-3">Bergabunglah dengan Kami</p>
        <h2 class="font-display text-3xl md:text-5xl font-bold text-forest mb-4">Jadi Member Yayasan</h2>
        <p class="text-gray-500 max-w-xl mx-auto">Daftar gratis sebagai member untuk mengikuti perjalanan penuh setiap program dan menjadi bagian dari perubahan.</p>
      </div>
      <div class="grid md:grid-cols-3 gap-6">
        <div v-for="b in benefits" :key="b.title" class="card-hover bg-white rounded-2xl p-6 border border-green-50 shadow-sm">
          <div class="flex items-center gap-3 mb-4">
            <div class="w-10 h-10 bg-mint rounded-xl flex items-center justify-center p-2">
              <img :src="b.icon" :alt="b.title" class="w-full h-full object-contain" />
            </div>
            <h4 class="font-bold text-forest">{{ b.title }}</h4>
          </div>
          <p class="text-gray-500 text-sm">{{ b.desc }}</p>
        </div>
      </div>
      <div class="text-center mt-12">
        <router-link
          v-if="!isLoggedIn"
          to="/daftar"
          class="inline-block bg-forest text-white px-10 py-4 rounded-full font-semibold hover:bg-leaf transition-all shadow-lg"
        >
          Daftar sebagai Member
        </router-link>
        <p v-else class="text-leaf font-semibold">Kamu sudah jadi member. Terima kasih! 💚</p>
      </div>
    </div>
  </section>
</template>