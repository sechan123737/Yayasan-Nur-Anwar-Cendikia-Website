<script setup>
const pillars = [
  { icon: '/images/Akses Pendidikan.png', title: 'Akses Pendidikan', desc: 'Menyediakan beasiswa, membangun sekolah, dan melatih guru di komunitas yang kurang terlayani di seluruh Indonesia.' },
  { icon: '/images/Kesejahteraan Sosial.png', title: 'Kesejahteraan Sosial', desc: 'Mendukung panti asuhan, program pemberian makan, dan inisiatif kesehatan untuk keluarga dan anak-anak yang rentan.' },
  { icon: '/images/Pertumbuhan Berkelanjutan.png', title: 'Pertumbuhan Berkelanjutan', desc: 'Memberdayakan komunitas dengan pelatihan vokasional, pembiayaan mikro, dan program konservasi lingkungan.' }
]
</script>

<template>
  <section id="about" class="py-24 bg-white scroll-mt-20">
    <div class="max-w-7xl mx-auto px-6">
      <div class="text-center mb-16">
        <p class="text-leaf font-semibold tracking-widest uppercase text-sm mb-3">Misi Kami</p>
        <h2 class="font-display text-3xl md:text-5xl font-bold text-forest mb-6">Membangun Jembatan menuju Masa Depan Cerah</h2>
        <p class="text-gray-500 max-w-2xl mx-auto text-lg">Kami percaya setiap anak berhak mendapatkan akses pendidikan berkualitas tanpa memandang latar belakang ekonomi. Yayasan kami bekerja tanpa henti untuk menciptakan perubahan berkelanjutan.</p>
      </div>
      <div class="grid md:grid-cols-3 gap-8">
        <div v-for="p in pillars" :key="p.title" class="card-hover p-8 rounded-3xl bg-cream border border-green-50 text-center">
          <div class="w-16 h-16 bg-mint rounded-2xl flex items-center justify-center mx-auto mb-5 p-3">
            <img :src="p.icon" :alt="p.title" class="w-full h-full object-contain" />
          </div>
          <h3 class="font-display font-bold text-xl text-forest mb-3">{{ p.title }}</h3>
          <p class="text-gray-500 text-sm leading-relaxed">{{ p.desc }}</p>
        </div>
      </div>
    </div>
  </section>
</template>