package org.tmkim.task;

import lombok.Setter;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.tmkim.domain.BoardAttachVO;
import org.tmkim.mapper.BoardAttachMapper;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Log4j2
@Component
public class FileCheckTask
{

    @Setter(onMethod_ = @Autowired)
    private BoardAttachMapper attachMapper;
    
    // 전날 등록된 파일들 중 DB에 없는 경우 모든 파일들을 찾아 삭제
    @Scheduled(cron = "0 0 2 * * *") // 매일 새벽2시
    public void checkFiles() throws Exception
    {
        log.warn("File Check Task run............");
        log.warn(new Date());

        // 데이터베이스 상의 파일들과 디렉토리 내의 파일들 준비
        List<BoardAttachVO> fileList = attachMapper.getOldFiles();
        List<Path> fileListPaths = fileList.stream()
                .map(vo -> Paths.get(
                        "c:\\upload", vo.getUploadPath(), vo.getUuid() + "_" + vo.getFileName())
                )
                .collect(Collectors.toList());

        // 지울 섬네일 파일들 추가
        fileList.stream()
                .filter(vo -> vo.isFileType() == true)
                .map(vo -> Paths.get(
                        "c:\\upload", vo.getUploadPath(), "s_" + vo.getUuid() + "_" + vo.getFileName())
                )
                .forEach(p -> fileListPaths.add(p));

        log.warn("=============================");

        fileListPaths.forEach(p -> log.warn(p));

        // 어제 디렉터리
        File targetDir = Paths.get("c:\\upload", getFolderYesterDay()).toFile();

        // 실제 폴더에 있는 파일들의 목록과 데이터 베이스에 없는 파일들 준비
        File[] removeFiles = targetDir.listFiles(file -> fileListPaths.contains(file.toPath()) == false);

        log.warn("--------------------------------");

        for(File file : removeFiles)
        {
            log.warn(file.getAbsolutePath());
            file.delete();
        }
    }

    private String getFolderYesterDay()
    {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, -1);

        String str = sdf.format(cal.getTime());
        return str.replace("-", File.separator);
    }
}
