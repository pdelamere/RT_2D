pro plot_2d,nf


  xsz = 1400.
  ysz = 1200.
  file = 'RT.mp4'
  width = xsz
  height = ysz
  frames = 180
  fps = 30
  speed = 2
  samplerate = 22050L
 
  ; Create object and initialize video/audio streams
;  oVid = IDLffVideoWrite(file)
;  vidStream = oVid.AddVideoStream(width, height, fps)

  video_file = 'RT.mp4'
  video = idlffvideowrite(video_file)
  framerate = 7.5
  stream = video.addvideostream(xsz, ysz, framerate)

 ; audStream = oVid.AddAudioStream(samplerate)

device,decomposed=0
loadct,27

dir = '/Volumes/Scratch/hybrid/RT/RT_bhs_4/'

nframe=nf
read_para,dir
restore,filename=dir+'para.sav'
read_coords,dir,x,y,z
@get_const


XINTERANIMATE, SET=[xsz,ysz, nframe], /SHOWLOAD 
w = window(dimensions=[xsz,ysz],/buffer)   

!p.multi=[0,3,1]
for nfrm = 1,nframe,1 do begin

   c_read_3d_vec_m_32,dir,'c.b1',nfrm,b1
   c_read_3d_vec_m_32,dir,'c.up',nfrm,up
   c_read_3d_m_32,dir,'c.np',nfrm,np
   c_read_3d_m_32,dir,'c.temp_p',nfrm,tp
   c_read_3d_m_32,dir,'c.mixed',nfrm,mix

   comegapi = (z(1)-z(0))*2

   bx = (reform(b1(*,1,*,0))*(mproton)/q)/1e-9
   by = (reform(b1(*,1,*,1))*(mproton)/q)/1e-9
   bz = (reform(b1(*,1,*,2))*(mproton)/q)/1e-9
;   b1(0,0,0,0) = 120.
   print,max(bx)
   w.erase

   nparr = reform(np(*,1,*))/1e15
   uparr = reform(up(*,1,*,2))
   tparr =  reform(tp(*,1,*))
   mixarr = reform(mix(*,0,*))
   sarr = tparr/nparr^(2./3.)

   im = image(by,/current,rgb_table=33,layout=[3,2,5],/buffer)
   xax = axis('x',axis_range=[0,max(x)],location=[0,0],thick=2)
   yax = axis('y',axis_range=[0,max(z)],location=[0,0],thick=2)

   ct = colorbar(target = im,title='$B_y$ (nT)',orientation=1,textpos=1,$
                 position=[1.01,0,1.1,1.0],/relative)

   im1 = image(nparr,/current,rgb_table=33,layout=[3,2,2],/buffer)
   xax = axis('x',axis_range=[0,max(x)],location=[0,0],thick=2,target=im1)
   yax = axis('y',axis_range=[0,max(z)],location=[0,0],thick=2,target=im1)

   ct = colorbar(target = im1,title='$n_p$ (cm$^{-3}$)',orientation=1,textpos=1,$
                position=[1.01,0,1.1,1.0],/relative)

   im2 = image(sarr,/current,rgb_table=33,layout=[3,2,4],/buffer)
   xax = axis('x',axis_range=[0,max(x)],location=[0,0],thick=2,target=im2)
   yax = axis('y',axis_range=[0,max(z)],location=[0,0],thick=2,target=im2)

   ct = colorbar(target = im2,title='entropy (T/n^2/3)',orientation=1,textpos=1,$
                 position=[1.01,0,1.1,1.0],/relative)

   im3 = image(tparr,/current,rgb_table=33,layout=[3,2,1],/buffer)
   xax = axis('x',axis_range=[0,max(x)],location=[0,0],thick=2,target=im3)
   yax = axis('y',axis_range=[0,max(z)],location=[0,0],thick=2,target=im3)

   ct = colorbar(target = im3,title='$T$ (eV)',orientation=1,textpos=1,$
                 position=[1.01,0,1.1,1.0],/relative)


   im4 = image(mixarr<1.0,/current,rgb_table=33,layout=[3,2,3],/buffer)
   xax = axis('x',axis_range=[0,max(x)],location=[0,0],thick=2,target=im4)
   yax = axis('y',axis_range=[0,max(z)],location=[0,0],thick=2,target=im4)

   ct = colorbar(target = im4,title='Mixing',orientation=1,textpos=1,$
                 position=[1.01,0,1.1,1.0],/relative)

   p = plot(z,nparr(nx/2,*),layout=[3,2,6],/buffer,/current)


;   im.scale,1.2,1.2

;   xdot = reform(up(*,1,*,0))
;   zdot = reform(up(*,1,*,2))

;   p = contour(arr,$
;               xarr,zarr,layout=[3,1,1],$
;               /current,/fill,rgb_table=33,n_levels=10,$
;               xtitle='x ($R_{Io}$)',ytitle='z ($R_{Io}$)',font_size=16,$
;               xstyle=1,xthick=2,ystyle=1,ythick=2,aspect_ratio=1.0,/buffer)

;   ct = colorbar(target = p,title='$B_x$ (nT)',orientation=1)

;   p1 = contour(arr,$
;               xarr,zarr,layout=[3,1,2],$
;               /current,/fill,rgb_table=33,n_levels=10,$
;               xtitle='x ($R_{Io}$)',ytitle='z ($R_{Io}$)',font_size=16,$
;               xstyle=1,xthick=2,ystyle=1,ythick=2,aspect_ratio=1.0,/buffer)

;   p2 = contour(arr,$
;               xarr,zarr,layout=[3,1,3],$
;               /current,/fill,rgb_table=33,n_levels=10,$
;               xtitle='x ($R_{Io}$)',ytitle='z ($R_{Io}$)',font_size=16,$
;               xstyle=1,xthick=2,ystyle=1,ythick=2,aspect_ratio=1.0,/buffer)

;   v = streamline(xdot,zdot,xarr,zarr,/current,overplot=1,$
;                 x_streamparticles=11,y_streamparticles=11)

;   time = oVid.Put(vidStream, w.CopyWindow())
;   w.close

;   plot,tm,(by*16*mp/q)/1e-9,xtitle='time (s)',xrange=[0,dt*nframe]

;   img = tvrd(0,0,xsz,ysz,true=1)
   img = w.CopyWindow()

;   tvscl,img
   print, 'Time:', video.put(stream, im.copywindow())
   xinteranimate, frame = nfrm-1, image = img


;   plot,tm,by,xtitle='time (s)'

endfor

video.cleanup

xinteranimate,/keep_pixmaps

return
end
