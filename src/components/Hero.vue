<script setup>
</script>

<template>
  <section class="relative pt-32 pb-24 md:pt-44 md:pb-36 gradient-overlay pattern-bg">
    <div class="max-w-7xl mx-auto px-6 text-center text-white">
      <p class="animate-fade-up text-mint/80 font-medium tracking-widest uppercase text-sm mb-4">Pendidikan • Pemberdayaan • Perubahan</p>
      <h1 class="animate-fade-up-2 font-display text-4xl md:text-6xl lg:text-7xl font-bold leading-tight mb-6 max-w-4xl mx-auto">Menerangi Masa Depan Melalui Pendidikan</h1>
      <p class="animate-fade-up-3 text-lg md:text-xl text-white/80 max-w-2xl mx-auto mb-10 font-light">Memberdayakan komunitas di seluruh Indonesia dengan akses pendidikan berkualitas, kesejahteraan sosial, dan program pembangunan berkelanjutan.</p>
      <div class="animate-fade-up-4 flex flex-col sm:flex-row gap-4 justify-center">
        <router-link to="/#donate" class="bg-white text-forest px-8 py-4 rounded-full font-semibold hover:bg-mint transition-all shadow-lg hover:shadow-xl">Donasi Sekarang</router-link>
        <router-link to="/#programs" class="border-2 border-white/40 text-white px-8 py-4 rounded-full font-semibold hover:bg-white/10 transition-all">Program Kami</router-link>
      </div>
    </div>
    <div class="absolute bottom-0 left-0 right-0">
      <svg viewBox="0 0 1440 80" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M0 80L1440 80L1440 40C1200 70 960 10 720 40C480 70 240 10 0 40L0 80Z" fill="#f9fcfa" />
      </svg>
    </div>
  </section>
</template>