package org.tmkim.service;

import lombok.Setter;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.tmkim.mapper.Sample1Mapper;
import org.tmkim.mapper.Sample2Mapper;

@Service
@Log4j2
public class SampleTxServiceImpl implements SampleTxService
{
    @Setter(onMethod_ = {@Autowired})
    public Sample1Mapper mapper1;

    @Setter(onMethod_ = {@Autowired})
    public Sample2Mapper mapper2;

    @Transactional
    @Override
    public void addData(String value)
    {
        log.info("mapper1...................");
        mapper1.insertCol1(value);

        log.info("mapper2...................");
        mapper2.insertCol2(value);

        log.info("end.......................");
    }
}
